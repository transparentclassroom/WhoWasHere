class Activity
  include ActiveModel::Model
  include ActiveModel::Attributes
  attr_accessor :school_id, :name

  attribute :timestamp, :datetime

  def self.log(user, school_id, name, time)
    activity = new(school_id: school_id, name: name, timestamp: time)
    user.last_visit.start_or_append(activity)
    activity
  end

  def activity_type
    calc_activity_type(name)
  end

  def to_h
    {
      school_id: school_id,
      name: name,
      timestamp: timestamp
    }
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
