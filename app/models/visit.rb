class Visit < ApplicationRecord
  require_dependency "activity_collection"
  DEFAULT_DURATION = 30
  INTERVAL = 10.minutes
  belongs_to :user

  attribute :start_at, Timestamp::Type.new
  attribute :end_at, Timestamp::Type.new

  before_save :update_start_and_end_at

  def update_start_and_end_at
    self.start_at = start_activity&.timestamp
    self.stop_at = stop_activity&.timestamp
  end

  attribute :activities, ActivityCollection::Type.new
  def self.start(user, activity)
    visit = user.visits.create!(school_id: activity.school_id, seconds: DEFAULT_DURATION)
    visit << activity
    visit
  end

  def last_activity
    activities.most_recent
  end
  alias_method :stop_activity, :last_activity

  def stop_at
    super || stop_activity&.timestamp || Time.zone.now
  end

  def start_activity
    activities.least_recent
  end

  def start_at
    super || start_activity&.timestamp
  end

  def minutes
    seconds / 6 / 10.0
  end

  def covers?(activity)
    school_id == activity.school_id &&
      (stop_at + Visit::INTERVAL).after?(activity.timestamp)
  end

  def start_or_append(activity)
    if covers?(activity)
      append(activity)
    else
      Visit.start(user, activity)
    end
  end

  def <<(activity)
    append(activity)
  end

  def append(activity)
    self.activities << (activity)
    self.update!(seconds: (stop_at.to_time - start_at.to_time) + DEFAULT_DURATION)
    self
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
