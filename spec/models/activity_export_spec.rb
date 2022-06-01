require 'rails_helper'

describe ActivityExport do
  before { ACTIVITY_ARCHIVE_BUCKET.clear }
  after { ACTIVITY_ARCHIVE_BUCKET.clear }

  def freeze_time(now = Time.now)
    allow(Time).to receive(:now).and_return(now)
    allow(Time.zone).to receive(:now).and_return(now)
  end

  def new_export(options)
    ActivityExport.new({ table: :activities }.merge(options))
  end

  describe '#initialize' do
    it 'should require activities or visits table' do
      new_export(table: :activities)
      new_export(table: :visits)
      expect { new_export(table: :something_else) }.to raise_error('table must be either :activites or :visits')
    end
  end

  describe '#filename' do
    it 'should have simple month filename' do
      expect(new_export(start_date: Date.new(2019, 2, 1)).filename).to eq('activities-201902.csv')
      expect(new_export(start_date: Date.new(2018, 3, 1)).filename).to eq('activities-201803.csv')
    end

    it 'should have specific start and stop dates if duration is not a month' do
      expect(new_export(start_date: Date.new(2018, 3, 2)).filename).to eq('activities-20180302-20180402.csv')
      expect(new_export(start_date: Date.new(2018, 3, 2), stop_date: Date.new(2018, 3, 9)).filename).to eq('activities-20180302-20180309.csv')
    end
  end

  describe "#premature?" do
    it "is true if it's the current month" do
      freeze_time(Time.utc(2019, 1, 20, 5, 23))
      expect(new_export(start_date: Date.new(2019, 1, 1))).to be_premature

      freeze_time(Time.utc(2019, 1, 31, 23, 59))
      expect(new_export(start_date: Date.new(2019, 1, 1))).to be_premature
    end

    it "is true if it's within a day of the previous month, so that we dont' blunder into timezone issues, and visits can be finished" do
      freeze_time(Time.utc(2019, 2, 1, 23, 59))
      expect(new_export(start_date: Date.new(2019, 1, 1))).to be_premature
    end

    it "is false if it's a previous month" do
      freeze_time(Time.utc(2019, 2, 2, 0, 1))
      expect(new_export(start_date: Date.new(2019, 1, 1))).not_to be_premature
    end

    it "is true if it's next month" do
      freeze_time(Time.utc(2019, 3, 2))
      expect(new_export(start_date: Date.new(2019, 1, 1))).not_to be_premature
    end

    it "is true if it's the exact moment this month begins" do
      freeze_time(Time.utc(2019, 1, 1))
      expect(new_export(start_date: Date.new(2019, 1, 1))).to be_premature
    end
  end

  describe "#generate" do
    it "doesnt run if the export is in the archive already" do
      archive = instance_double(ActivityExport::Archive, upload: true)

      export = new_export(archive: archive)
      allow(archive).to receive(:archived?).with(filename: export.filename).and_return(true)

      result = export.generate

      aggregate_failures do
        expect(result).to be_falsey
        expect(export).to be_unnecessary
        expect(export.start_date).to eql(1.month.ago.beginning_of_month.to_date)
        expect(archive).not_to have_received(:upload)
      end
    end

    it "will not run if the month is the current month" do
      archive = instance_double(ActivityExport::Archive, upload: true, archived?: false)
      export = new_export(archive: archive, start_date: Date.today.beginning_of_month)

      result = export.generate

      aggregate_failures do
        expect(result).to be_falsey
        expect(export).to be_premature
        expect(archive).not_to have_received(:upload)
      end
    end

    it "uploads the previous months activities the the archive repository" do
      archive = instance_double(ActivityExport::Archive, upload: true, archived?: false, content_length: 100)
      export = new_export(archive: archive, start_date: Time.zone.yesterday.beginning_of_month - 1.month)
      allow(export).to receive(:psql_export_to_csv) do |query_sql:, file:|
        file.write <<~CSV
          user_id,school_id,activity_type,name,created_at
          1,1,foo,foo,2019-01-01 01:01:01
        CSV
      end
      result = export.generate
      aggregate_failures do
        expect(result).to be_truthy
        expect(export.archive).to have_received(:upload).with(filename: export.filename, file: export.file)
      end
    end

    it "should blow up if the file that is generated is less than 80 bytes" do
      archive = instance_double(ActivityExport::Archive, archived?: false)
      export = new_export(archive: archive, start_date: Time.zone.yesterday.beginning_of_month - 1.month)
      allow(export).to receive(:psql_export_to_csv) do |query_sql:, file:|
        file.write <<~CSV
          user_id,school_id,activity_type,name,created_at
        CSV
      end
      expect { export.generate }.to raise_error('Generated CSV file is only 48 bytes, please investigate')
    end

    it "should blow up if the file that is uploaded is less than 80 bytes" do
      archive = instance_double(ActivityExport::Archive, upload: true, archived?: false, content_length: 79)
      export = new_export(archive: archive, start_date: Time.zone.yesterday.beginning_of_month - 1.month)
      allow(export).to receive(:psql_export_to_csv) do |query_sql:, file:|
        file.write <<~CSV
          user_id,school_id,activity_type,name,created_at
          1,1,foo,foo,2019-01-01 01:01:01
        CSV
      end
      expect { export.generate }.to raise_error('Uploaded file is only 79 bytes, please investigate')
    end
  end

  describe ActivityExport::Archive do
    let(:archive) { ActivityExport::Archive.new }

    describe "#upload" do
      it 'uploads the gzipped contents to the s3 bucket' do
        file = Tempfile.new
        file.puts("hello there")

        archive.upload(file: file, filename: '2019-02.csv')
        expect(archive.s3.object('2019-02.csv.gz').exists?).to eq true
      end
    end

    describe "#download" do
      it 'should download an uploaded file' do
        file = Tempfile.new
        file.write('Hello there')
        file.rewind

        archive.upload(file: file, filename: '2019-02.csv')
        expect(archive.download(filename: '2019-02.csv').read).to eq('Hello there')
      end
    end

    describe "#archived?" do
      it "is true when the bucket has a file for the given month" do
        file = Tempfile.new
        file.write('Hello there')

        archive.upload(file: file, filename: '2019-02.csv')

        expect(archive.archived?(filename: '2019-02.csv')).to be_truthy
      end

      it "is false when the bucket does not have a file for the given month" do
        archive = ActivityExport::Archive.new
        expect(archive.archived?(filename: '2019-02.csv')).to be_falsey
      end
    end
  end

  describe "Exporting" do
    context 'activities' do
      it "uploads the file to S3 w/o actually calling psql" do
        export = new_export(table: :activities, start_date: Date.new(2019, 1))
        allow(export).to receive(:psql_export_to_csv) do |query_sql:, file:|
          expect(query_sql).to eq <<~SQL
            select user_id, school_id, activity_type, name, created_at
            from activities
            where created_at between '2019-01-01' and '2019-02-01'
            order by created_at
          SQL
          file.write <<~CSV
            user_id,school_id,activity_type,name,created_at
            1,1,something,something,2019-01-05 12:13:00
          CSV
          file.rewind
        end

        export.generate
        expect(export.archive.s3.object('activities-201901.csv.gz').exists?).to eq true

        file = export.download
        expected = <<~CSV
          user_id,school_id,activity_type,name,created_at
          1,1,something,something,2019-01-05 12:13:00
        CSV

        expect(file.read).to eq(expected)
      end
    end

    context 'visits' do
      it "uploads the file to S3 w/o actually calling psql" do
        export = new_export(table: :visits, start_date: Date.new(2019, 1))
        allow(export).to receive(:psql_export_to_csv) do |query_sql:, file:|
          expect(query_sql).to eq <<~SQL
            select user_id, school_id, start_at, stop_at, seconds
            from visits
            where start_at between '2019-01-01' and '2019-02-01'
            order by start_at
          SQL
          file.write <<~CSV
            user_id,school_id,activity_type,name,created_at
            1,1,something,something,2019-01-05 12:13:00
          CSV
          file.rewind
        end

        export.generate
        file = export.download

        expected = <<~CSV
          user_id,school_id,activity_type,name,created_at
          1,1,something,something,2019-01-05 12:13:00
        CSV

        expect(file.read).to eq(expected)
      end
    end
  end
end
