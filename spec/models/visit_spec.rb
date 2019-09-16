require 'rails_helper'

RSpec.describe Visit, type: :model do
  let(:school_id) { 5 }
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:user3) { FactoryBot.create(:user) }

  def create_visit!(args)
    args[:school_id] = school_id
    args[:seconds] = args[:seconds].to_i
    args[:start_activity] ||= Activity.create! school_id: school_id, user: args[:user], name: 'bob'
    args[:stop_activity] ||= args[:start_activity]
    Visit.create! args
  end

  describe 'sparkline_by_user' do
    it 'should return minutes per day' do
      Time.zone = 'UTC'

      today = Time.zone.today

      create_visit! user: user1, start_at: today - 1.day + 1.hour, seconds: 30.minutes
      create_visit! user: user1, start_at: today - 2.day + 1.hour, seconds: 30.minutes
      create_visit! user: user1, start_at: today - 2.day + 1.hour, seconds: 15.minutes
      create_visit! user: user1, start_at: today - 4.day + 1.hour, seconds: 15.seconds
      create_visit! user: user2, start_at: today - 1.day + 1.hour, seconds: 52.minutes

      ids = [user1, user2, user3].map(&:id)
      expect(Visit::sparkline_by_user(school_id, ids))
          .to eq({
              user1.id => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0, 45.0, 30.0, 0],
              user2.id => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 52.0, 0],
              user3.id => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
          })
    end
  end
end
