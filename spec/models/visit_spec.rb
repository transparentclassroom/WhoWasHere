require "rails_helper"

RSpec.describe Visit, type: :model do
  let(:school_id) { 5 }
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:user3) { FactoryBot.create(:user) }

  def create_visit!(args)
    args[:school_id] = school_id
    args[:seconds] = args[:seconds].to_i
    start_at = args.delete(:start_at)
    args[:activities] = [Activity.new(timestamp: start_at)] if start_at
    Visit.create! args
  end

  describe "sparkline_by_user" do
    it "should return minutes per day" do
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

  describe "#append(activity)" do
    it "Adds to the activities collection" do
      visit = Visit.new(user: FactoryBot.create(:user))
      activity = Activity.new(timestamp: Time.zone.now)
      visit.append(activity)

      aggregate_failures do
        expect(visit.activities.length).to eql(1)
        expect(visit.activities).to include(activity)
        expect(visit.start_activity).to eql(activity)
        expect(visit.stop_activity).to eql(activity)
        expect(visit.seconds).to eql(Visit::DEFAULT_DURATION)
      end
    end

    it "Pushes out the seconds" do
      visit = Visit.new(user: FactoryBot.create(:user))
      first = Activity.new(timestamp: 30.seconds.ago)
      visit.append(first)
      second = Activity.new(timestamp: 0.seconds.ago)
      visit.append(second)

      aggregate_failures do
        expect(visit.activities.length).to eql(2)
        expect(visit.activities).to include(first)
        expect(visit.activities).to include(second)
        expect(visit.start_activity).to eql(first)
        expect(visit.stop_activity).to eql(second)
        expect(visit.seconds).to eql(60)
      end
    end
  end
end
