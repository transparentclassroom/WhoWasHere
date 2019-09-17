class Visit < ApplicationRecord
  require_dependency "activity_collection"
  INTERVAL = 10.minutes
  belongs_to :user

  attribute :activities, ActivityCollection::Type.new, default: ActivityCollection.new
  def self.start(user, activity)
    visit = user.visits.create!(school_id: activity.school_id, seconds: 30)
    visit << activity
    visit
  end

  def last_activity
    activities.most_recent
  end
  alias_method :stop_activity, :last_activity

  def stop_at
    stop_activity&.timestamp || Time.now.utc
  end

  def start_activity
    activities.least_recent
  end

  def start_at
    start_activity&.timestamp
  end

  def minutes
    seconds / 6 / 10.0
  end

  def covers?(activity)
    stop_at + Visit::INTERVAL > activity.timestamp
  end

  def start_or_append(activity)
    return append(activity) if covers?(activity)
    Visit.start(user, activity)
  end

  def <<(activity)
    append(activity)
  end

  def append(activity)
    self.activities << (activity)
    self.seconds = stop_at - start_at + 30
    save!
  end

  SPARKLINE_WINDOW = 14 # in days
  def self.sparkline_by_user(school_id, user_ids)
    visits = Visit
      .where(school_id: school_id)
      .where(user_id: user_ids)
      .select("user_id, sum(seconds) as seconds, date(start_at) as start_at")
      .where("start_at >= ?", SPARKLINE_WINDOW.days.ago)
      .group("start_at, user_id")

    usage_by_user = user_ids.each_with_object({}) { |id, acc| acc[id.to_i] = Array.new(SPARKLINE_WINDOW, 0); }
    today = Time.zone.today
    visits.each do |visit|
      day = SPARKLINE_WINDOW - 1 - (today - visit.start_at.to_date)
      row = usage_by_user[visit.user_id]
      row[day] = visit.seconds / 60.0
    end
    usage_by_user
  end
end
