class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :visit, optional: true # optional, because activity is created first, and exists for a moment w/o a visit

  def self.log(user, school_id, name, time)
    activity = Activity.create!(user: user, school_id: school_id, name: name, created_at: time)
    user.last_activity = activity

    if user.last_visit&.includes?(activity)
      user.last_visit.append(activity)
    else
      user.last_visit = Visit.start(user, activity)
    end
    user.save

    activity.visit = user.last_visit
    activity.save!
    activity
  end

  def name=(value)
    self[:name] = value
    self.activity_type = calc_activity_type(value)
  end

  private

  def calc_activity_type(value)
    value.gsub(/\?(.*)/) {
      if $1 =~ /^log=([^&]+)/
        "##{$1}"
      else
        ""
      end
    }
      .gsub(/ \/s\/\d+\//, " /")
      .gsub(/\d+/, "X")
  end
end
