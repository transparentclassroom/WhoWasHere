require "rails_helper"

RSpec.describe Activity, type: :model do
  describe ".log" do
    let(:school_id) { 5 }
    let(:u) { FactoryBot.create(:user) }
    let(:time) { Time.new(2019, 10, 1, 5, 6, 7) }

    it "creates an activitiy within a visit associated to the school and user" do
      activity = (Activity.log u, school_id, "Yelling at the kids", time)

      aggregate_failures do
        expect(activity.name).to eq("Yelling at the kids")
        expect(activity.school_id).to eq(school_id)

        u.reload

        expect(u.last_visit).to be_present
        expect(u.last_visit.activities).to include(activity)
        expect(u.last_visit.start_activity).to eql(activity)
        expect(u.last_visit.stop_activity).to eql(activity)
      end
    end

    it "should create a visit on first log" do
      activity = Activity.log u, school_id, "Flying", time

      u.reload
      visit = u.last_visit

      expect(visit.seconds).to eq(30)
      expect(visit.start_activity).to eq(activity)
      expect(visit.stop_activity).to eq(activity)
    end

    it "should add to it as long as interval < visit::INTERVAL" do
      start = now = Time.zone.now - 1.day

      one = Activity.log u, school_id, "one", now
      visit = u.reload.last_visit
      aggregate_failures do
        expect(visit.start_at).to eql(one.timestamp)
        expect(visit.stop_at).to eql(one.timestamp)
        expect(visit.seconds).to eql(30)
        expect(visit.start_activity).to eql(one)
        expect(visit.stop_activity).to eql(one)
      end

      now += 40.seconds

      two = Activity.log u, school_id, "two", now

      visit = u.reload.last_visit

      aggregate_failures do
        expect(visit.start_at).to eql(one.timestamp)
        expect(visit.stop_at).to eql(two.timestamp)
        expect(visit.seconds).to eql(30 + 40)
        expect(visit.start_activity).to eql(one)
        expect(visit.stop_activity).to eql(two)
      end

      now += 55.seconds
      three = Activity.log u, school_id, "three", now
      visit = u.reload.last_visit

      aggregate_failures do
        expect(visit.start_at).to eql(one.timestamp)
        expect(visit.stop_at).to eql(three.timestamp)
        expect(visit.seconds).to eql(30 + 40 + 55)
        expect(visit.start_activity).to eql(one)
        expect(visit.stop_activity).to eql(three)
      end
    end

    it "should create a new visit if interval > visit::INTERVAL" do
      now = Time.zone.now - 1.day

      one = Activity.log u, school_id, "one", now
      visit = u.reload.last_visit
      aggregate_failures do
        expect(visit.start_at).to eql(one.timestamp)
        expect(visit.stop_at).to eql(one.timestamp)
        expect(visit.seconds).to eql(30)
        expect(visit.start_activity).to eql(one)
        expect(visit.stop_activity).to eql(one)
      end

      later = now + Visit::INTERVAL + 31.second
      two = Activity.log u, school_id, "two", later

      visit = u.reload.last_visit
      aggregate_failures do
        expect(visit.start_at).to eql(two.timestamp)
        expect(visit.stop_at).to eql(two.timestamp)
        expect(visit.seconds).to eql(30)
        expect(visit.start_activity).to eql(two)
        expect(visit.stop_activity).to eql(two)
      end
    end
  end

  describe "activity_type" do
    it "should generate activity type free of ids" do
      expect(Activity.new(name: "GET /pages/all").activity_type).to eq("GET /pages/all")
      expect(Activity.new(name: "GET /s/235/pages/all").activity_type).to eq("GET /pages/all")
      expect(Activity.new(name: "GET /s/235/pages/23.json").activity_type).to eq("GET /pages/X.json")
      expect(Activity.new(name: "GET /s/235/pages/23/sort").activity_type).to eq("GET /pages/X/sort")
    end

    it "should remove params except the log param" do
      expect(Activity.new(name: "POST /pages/all?foo=bar&stuff").activity_type).to eq("POST /pages/all")
      expect(Activity.new(name: "POST /pages/all?log=foo_bar&stuff").activity_type).to eq("POST /pages/all#foo_bar")
      expect(Activity.new(name: "POST /pages/all?log=foo_bar").activity_type).to eq("POST /pages/all#foo_bar")
    end
  end
end
