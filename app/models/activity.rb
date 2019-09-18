class Activity
  include ActiveModel::Model
  include ActiveModel::Attributes
  attr_accessor :school_id, :name

  attribute :timestamp, Timestamp::Type.new

  def self.log(user, school_id, name, time)
    activity = new(school_id: school_id, name: name, timestamp: time)
    user.last_visit.start_or_append(activity)
    activity
  end

  def activity_type
    calc_activity_type(name)
  end

  def <=>(other)
    other.timestamp <=> timestamp
  end

  def to_h
    {
      school_id: school_id,
      name: name,
      timestamp: timestamp
    }
  end

  def inspect
    "#<#{self.class.name} #{to_h}>"
  end

  def eql?(other)
    self.==(other)
  end

  def ==(other)
    to_h == other.to_h
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
