class Timestamp < DateTime
  class Type < ActiveModel::Type::DateTime
    def cast_value(value)
      value = value.change(usec: 0) if(value.respond_to?(:change))
      super(value)
    end

    def serialize(value)
      super(value)
    end
  end
end