require "rails_helper"

RSpec.describe Api::SparklinesController, type: :controller do
  let(:school_id) { 5 }
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }

  def create_visit!(args)
    args[:school_id] = school_id
    args[:seconds] = args[:seconds].to_i
    args[:start_activity] ||= Activity.create! school_id: school_id, user: args[:user], name: "bob"
    args[:stop_activity] ||= args[:start_activity]
    Visit.create! args
  end

  describe "#index" do
    it "should return several sparklines" do
      Time.zone = "UTC"

      today = Time.zone.today

      create_visit! user: user1, start_at: today - 1.day + 1.hour, seconds: 30.minutes

      get :index, params: { school_id: school_id,
                            ids: [user1.id, -1], }

      expect(JSON.parse(response.body))
          .to eq(
                  user1.id.to_s => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 30.0, 0],
                  -1.to_s => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
              )
    end

    it "should handle no user_ids" do
      get :index, params: { school_id: school_id }
    end
  end
end
