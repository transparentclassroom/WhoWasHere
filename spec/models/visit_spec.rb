require "rails_helper"

RSpec.describe Visit, type: :model do
  it { is_expected.to have_many(:activities).dependent(:destroy) }

  let(:school_id) { 5 }
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:user3) { FactoryBot.create(:user) }

  def create_visit!(args)
    args[:school_id] = school_id
    args[:seconds] = args[:seconds].to_i
    args[:start_activity] ||= Activity.create! school_id: school_id, name: "bob"
    args[:stop_activity] ||= args[:start_activity]
    Visit.create! args
  end

  describe ".destroy_before" do
    it "destroys visits that ended before the provide date or time" do
      ancient_activity = Activity.create(school_id:, name: "Something")
      ancient_visit = create_visit!(
        user: user1,
        start_activity: ancient_activity,
        start_at: 7.years.ago.beginning_of_day - 10.seconds,
        stop_at: 7.years.ago.beginning_of_day - 1.second)
      ancient_visit.activities << ancient_activity

      not_quite_ancient_activity = Activity.create(school_id:, name: "Something")
      not_quite_ancient_visit = create_visit!(
        user: user1,
        start_activity: not_quite_ancient_activity,
        start_at: 7.years.ago.beginning_of_day - 10.seconds,
        stop_at: 7.years.ago.beginning_of_day)

      not_quite_ancient_visit.activities << not_quite_ancient_activity

      expect(Visit).to exist(id: ancient_visit.id)
      expect(Visit).to exist(id: not_quite_ancient_visit.id)

      Visit.destroy_before(7.years.ago.beginning_of_day)

      expect(Visit).not_to  exist(id: ancient_visit.id)
      expect(Activity).not_to exist(visit_id: ancient_visit.id)
      expect(Visit).to exist(id: not_quite_ancient_visit.id)
      expect(Activity).to exist(visit_id: not_quite_ancient_visit.id)
    end
  end

  describe "sparkline_by_user" do
    it "should return minutes per day" do
      Time.zone = "UTC"

      today = Time.zone.today

      create_visit! user: user1, start_at: today - 1.day + 1.hour, seconds: 30.minutes
      create_visit! user: user1, start_at: today - 2.day + 1.hour, seconds: 30.minutes
      create_visit! user: user1, start_at: today - 2.day + 1.hour, seconds: 15.minutes
      create_visit! user: user1, start_at: today - 4.day + 1.hour, seconds: 15.seconds
      create_visit! user: user2, start_at: today - 1.day + 1.hour, seconds: 52.minutes

      ids = [user1, user2, user3].map(&:id)
      expect(Visit.sparkline_by_user(school_id, ids))
        .to eq({
          user1.id => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0, 45.0, 30.0, 0],
          user2.id => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 52.0, 0],
          user3.id => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        })
    end
  end
end
