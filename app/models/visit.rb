class Visit < ApplicationRecord
  INTERVAL = 10.minutes
  belongs_to :user
  belongs_to :start_activity, class_name: "Activity"
  belongs_to :stop_activity, class_name: "Activity"
  has_many :activities

  def minutes
    seconds / 6 / 10.0
  end

  def self.start(user, activity)
    Visit.create! school_id: activity.school_id,
                  user: user,
                  start_activity: activity,
                  start_at: activity.created_at,
                  stop_activity: activity,
                  stop_at: activity.created_at,
                  seconds: 30
  end

  def includes?(activity)
    stop_at + Visit::INTERVAL > activity.created_at
  end

  def append(activity)
    self.stop_activity = activity
    self.stop_at = activity.created_at
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
