namespace :export do
  desc "Exports the activities for the previous month"
  task :activity, [:start_date, :stop_date] => [:environment] do |_, args|
    begin
      [:activities, :visits].each do |table|
        export = ActivityExport.new(args.to_h.compact.merge(table: table))
        puts "Exporting #{table} from #{export.start_date} - #{export.stop_date}"
        export.generate
      end
    rescue
      TcErrorNotifier.error($!)
    end
  end

  desc "Exports the activities since the beginning of time"
  task :all_activity => [:environment] do
    puts "Exporting Activity for...".bold
    begin
      month = Activity.first.created_at.to_date.beginning_of_month
      while month < Date.today
        puts "Exporting #{month}..."
        [:activities, :visits].each do |table|
          export = ActivityExport.new(start_date: month, table: table)

          if export.generate
            puts "Exported #{table} for #{month}".green
          else
            puts "Skipped #{table} for #{month}"
          end
        end
        month += 1.month
      end
    rescue
      TcErrorNotifier.error($!)
    end
  end

  desc "Export activity locally, without pushing to s3 or checking if it should"
  task :activity_locally, [:start_date, :stop_date] => [:environment] do |_, args|
    args = args.to_h
    args[:start_date] ||= 2.weeks.ago.to_date
    [:activities, :visits].each do |table|
      export = ActivityExport.new(args.compact.merge(table: table))
      puts "Exporting #{table} from #{export.start_date} - #{export.stop_date}"
      export.generate_locally
      puts "#{table.to_s.titleize} finished: #{export.file.path}"
    end
  end
end