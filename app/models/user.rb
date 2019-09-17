class User < ApplicationRecord
  has_many :visits
  belongs_to :last_visit, class_name: "Visit", optional: true
  has_many :activities
  belongs_to :last_activity, class_name: "Activity", optional: true
end
