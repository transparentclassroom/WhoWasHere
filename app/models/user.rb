class User < ApplicationRecord
  has_many :visits

  def last_visit
    @last_visit ||= (self.visits.order(created_at: :desc).limit(1).first || Visit.new(user: self, activities: []))
  end
end
