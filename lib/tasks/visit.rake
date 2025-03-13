namespace :visit do
  desc "Truncates visits that ended more than VISIT_TRUNCATION_PERIOD days ago"
  task :truncate do
    if !ENV.key?("VISIT_TRUNCATION_PERIOD")
      raise ArgumentError, "Set a VISIT_TRUNCATION_PERIOD environment variable"
    end

    truncation_period = ENV.fetch("VISIT_TRUNCATION_PERIOD")

    if !truncation_period.match?(/^\d+$/)
      raise ArgumentError, "VISIT_TRUNCATION_PERIOD must be an integer"
    end


    Visit.destroy_before(truncation_period.to_i.days.ago.beginning_of_day)
  end
end