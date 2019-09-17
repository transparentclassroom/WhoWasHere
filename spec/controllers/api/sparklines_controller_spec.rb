require "rails_helper"

RSpec.describe Api::SparklinesController, type: :controller do
  let(:school_id) { 5 }
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }

  describe "#index" do
    it "should return several sparklines" do
      Time.zone = "UTC"

      today = Time.zone.today

      Visit.create! user: user1, activities: [Activity.new(timestamp: today - 1.day + 1.hour)], seconds: 30.minutes.to_i

      get :index, params: {school_id: school_id,
                           ids: [user1.id, -1],}

      expect(JSON.parse(response.body))
        .to eq(
          user1.id.to_s => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 30.0, 0],
          -1.to_s => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        )
    end
  end
end
