class ActivityExport
  attr_accessor :table, :archive, :start_date, :stop_date, :file

  # we do not import activity on the stop date,
  # so  start_date: 3/1, stop_date: 4/1 => all the activity in March and none in April
  def initialize(table:, archive: Archive.new, start_date: Time.zone.today.beginning_of_month - 1.month, stop_date: nil)
    raise('table must be either :activites or :visits') unless [:activities, :visits].include?(table)
    self.table, self.archive, self.start_date = table, archive, start_date.to_date
    self.stop_date = stop_date ? stop_date.to_date : self.start_date + 1.month
  end

  # Pulls records from postgresql, then uploads them to S3
  #
  # @return Boolean
  def generate
    return false if unnecessary? || premature?

    generate_locally
    upload
    true
  end

  def generate_locally
    self.file = pull_activities_into_temp_csv_file
    raise("Generated CSV file is only #{file.size} bytes, please investigate") unless file.size >= 80
  end

  def upload
    archive.upload(filename: filename, file: file)
    unless (size = archive.content_length(filename: filename)) >= 80
      raise("Uploaded file is only #{size} bytes, please investigate")
    end
  end

  def download
    archive.download(filename: filename)
  end

  def unnecessary?
    archive.archived?(filename: filename)
  end

  def filename
    if start_date == start_date.beginning_of_month && stop_date == start_date + 1.month
      "#{table}-#{start_date.strftime("%Y%m")}.csv"
    else
      "#{table}-#{start_date.strftime("%Y%m%d")}-#{stop_date.strftime("%Y%m%d")}.csv"
    end
  end

  def premature?
    Time.now <= stop_date + 1.day
  end

  private

  def pull_activities_into_temp_csv_file
    file = File.new(Archive.new_tempfile_path(filename: filename), 'w')
    columns, date_col = if table == :activities
                          [%w(user_id school_id activity_type name created_at), 'created_at']
                        else
                          [%w(user_id school_id start_at stop_at seconds), 'start_at']
                        end

    query_sql = <<~SQL
      select #{columns.join(', ')}
      from #{table}
      where #{date_col} between '#{start_date}' and '#{stop_date}'
      order by #{date_col}
    SQL

    psql_export_to_csv(query_sql: query_sql, file: file)
    file
  end

  CSV_OPTIONS = "FORMAT csv, DELIMITER ',',  HEADER true"

  # In order to create a csv file locally (and not on the postgres server) we need to go through psql
  #
  # Because of this, we can't test it inside of rspec, because it runs outside of our tests' transactions and
  # can't see records created by the tests.
  #
  # To test it manually, run `rake export:activity_test` and verify that you get a valid csv file
  def psql_export_to_csv(query_sql:, file:)
    psql_execute("\\copy (#{query_sql.gsub("\n", ' ')}) to '#{file.path.to_s}' with (#{CSV_OPTIONS})")
  end

  def psql_execute(sql)
    Rails.logger.info("running sql w/ psql: #{sql}")
    cmd = if Rails.env.production?
            "psql #{ENV['DATABASE_URL']} -c \"#{sql}\""
          else
            config = Rails.configuration.database_configuration[Rails.env]
            "psql -U #{config['username']} -d #{config['database']} -c \"#{sql}\""
          end
    `#{cmd}`
  end

  class Archive
    attr_accessor :s3

    def initialize(s3: ACTIVITY_ARCHIVE_BUCKET)
      self.s3 = s3
    end

    def upload(filename:, file:)
      object(filename).upload_file(gzip(file))
    end

    def download(filename:)
      output_path = Archive.new_tempfile_path(filename: gzipped_name(filename))
      object(filename).download_file(output_path)
      # I'm a little worried about where these file pointers wind up
      # Are they garbage collected at some point? We have 3 all in one method
      # and that seems excessive (output, gz, and f from File.open).
      gunzip(File.new(output_path))
    end

    def archived?(filename:)
      object(filename).exists?
    end

    def self.new_tempfile_path(filename:)
      Rails.root.join('tmp', filename)
    end

    def content_length(filename:)
      object(filename).content_length
    end

    private

    def object(filename)
      s3.object(gzipped_name(filename))
    end

    def gzipped_name(name)
      "#{name}.gz"
    end

    def gzip(file)
      new_path = gzipped_name(file.path)
      File.delete(new_path) while File.exists?(new_path)
      `gzip #{file.path}`
      File.new(new_path)
    end

    def gunzip(file)
      new_path = file.path.sub(/\.gz$/, '')
      File.delete(new_path) if File.exists?(new_path)

      raise "Unknown suffix" unless file.path.ends_with?('.gz')
      `gzip -d #{file.path}`

      File.new(new_path)
    end
  end
end
