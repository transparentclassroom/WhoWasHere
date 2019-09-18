# A sequence of activities ordered by timestamp
class ActivityCollection
  attr_accessor :activities
  delegate :include?, :map, :each, :length, :[], to: :activities

  def initialize(activities = [])
    self.activities = activities
  end

  def least_recent
    activities.last
  end
  alias_method :first, :least_recent

  def most_recent
    activities.first
  end
  alias_method :last, :most_recent

  def <<(activity)
    splice(activity.respond_to?(:timestamp) ? activity : Activity.new(activity))
  end

  private def splice(activity)
    activities.unshift(activity)
    activities.sort!
    self
  end

  def to_s
    to_h.to_s
  end

  class Type < ActiveModel::Type::Value
    def changed?(old_value, new_value, _new_value_before_type_cast)
      old_value != new_value
    end

    def changed_in_place?(raw_old_value, new_value)
      deserialize(raw_old_value) != new_value
    end

    def cast_value(value)
      return ActivityCollection.new if value.nil? || value.blank?
      return value if value.is_a?(ActivityCollection)
      return ActivityCollection.new(value) if value.respond_to?(:each)
      activity_collection = ActivityCollection.new
      JSON.parse(value, symbolize_names: true).map do |activity_attributes|
        activity_collection << Activity.new(activity_attributes)
      end
      activity_collection
    end

    def serialize(value)
      return [] if value.blank?
      JSON.dump(value.map(&:to_h))
    end
  end
end