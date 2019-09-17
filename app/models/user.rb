class User < ApplicationRecord
  has_many :visits
  belongs_to :last_visit, class_name: "Visit", optional: true

  def last_visit
    super || Visit.new(user: self, activities: [])
  end
end
