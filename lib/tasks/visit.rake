def truncation_period
  return @truncation_period if defined?(@truncation_period)

  @truncation_period = ENV.fetch("VISIT_TRUNCATION_PERIOD")

  if !@truncation_period.match?(/^\d+$/)
    raise ArgumentError, "VISIT_TRUNCATION_PERIOD must be an integer"
  end

  @truncation_period
rescue KeyError => e
  raise ArgumentError, "Set a VISIT_TRUNCATION_PERIOD environment variable"
end

namespace :visit do
  desc "Truncates visits that ended more than VISIT_TRUNCATION_PERIOD days ago"
  task :truncate do
    Visit.destroy_before(truncation_period.to_i.days.ago.beginning_of_day)
  end
end