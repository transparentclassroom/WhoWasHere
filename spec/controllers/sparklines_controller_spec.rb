require 'rails_helper'

RSpec.describe SparklinesController, type: :controller do
  let(:school_id) { 5 }
  let(:user1) { User.create! email: 'one@gmail.com' }
  let(:user2) { User.create! email: 'two@gmail.com' }

  def create_visit!(args)
    args[:school_id] = school_id
    args[:seconds] = args[:seconds].to_i
    args[:start_activity] ||= Activity.create! school_id: school_id, user: args[:user], name: 'bob'
    args[:stop_activity] ||= args[:start_activity]
    Visit.create! args
  end

  describe '#index' do
    it 'should return several sparklines' do
      Time.zone = 'UTC'

      today = Time.zone.today

      create_visit! user: user1, start_at: today - 1.day + 1.hour, seconds: 30.minutes

      get :index, params: { school_id: school_id,
                            emails: [user1.email, 'foo@example.com'] }

      expect(JSON.parse(response.body))
          .to eq(
                  user1.email =>       [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 30.0, 0],
                  'foo@example.com' => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
              )
    end
  end
end
