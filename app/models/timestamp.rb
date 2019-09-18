class Timestamp < DateTime
  class Type < ActiveModel::Type::DateTime
    def cast_value(value)
      value = value.change(usec: 0) if(value.respond_to?(:change))
      value = value.to_datetime if value.respond_to?(:to_datetime)
      super(value)
    end

    def serialize(value)
      super(value)
    end
  end
end