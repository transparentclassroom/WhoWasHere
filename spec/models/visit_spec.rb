require 'rails_helper'

RSpec.describe Visit, type: :model do
  let(:school_id) { 5 }
  let(:user1) { User.create! email: 'one@gmail.com' }
  let(:user2) { User.create! email: 'two@gmail.com' }
  let(:user3) { User.create! email: 'three@gmail.com' }

  def create_visit!(args)
    args[:school_id] = school_id
    args[:seconds] = args[:seconds].to_i
    args[:start_activity] ||= Activity.create! school_id: school_id, user: args[:user], name: 'bob'
    args[:stop_activity] ||= args[:start_activity]
    Visit.create! args
  end

  describe 'sparkline_by_email' do
    it 'should return minutes per day' do
      Time.zone = 'UTC'

      today = Time.zone.today

      create_visit! user: user1, start_at: today - 1.day + 1.hour, seconds: 30.minutes
      create_visit! user: user1, start_at: today - 2.day + 1.hour, seconds: 30.minutes
      create_visit! user: user1, start_at: today - 2.day + 1.hour, seconds: 15.minutes
      create_visit! user: user1, start_at: today - 4.day + 1.hour, seconds: 15.seconds
      create_visit! user: user2, start_at: today - 1.day + 1.hour, seconds: 52.minutes

      emails = [user1, user2, user3].map(&:email)
      expect(Visit::sparkline_by_email(school_id, emails))
          .to eq({
              user1.email => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0, 45.0, 30.0, 0],
              user2.email => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 52.0, 0],
              user3.email => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
          })
    end
  end
end
