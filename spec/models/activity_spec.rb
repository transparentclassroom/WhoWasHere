require "rails_helper"

RSpec.describe Activity, type: :model do
  it { is_expected.to belong_to(:visit).optional }
  it { is_expected.to have_one(:user).through(:visit) }
  it { is_expected.to delegate_method(:id).to(:user).with_prefix.allow_nil }

  describe ".log" do
    let(:school_id) { 5 }
    let(:u) { FactoryBot.create(:user) }
    let(:time) { Time.new(2019, 10, 1, 5, 6, 7) }

    it "should create an activity and associate it with a map / name" do
      Activity.log u, school_id, "Yelling at the kids", time

      u.reload
      expect(u.last_activity.name).to eq("Yelling at the kids")
      expect(u.last_activity.school_id).to eq(school_id)
      expect(u.last_activity.visit).to eq(u.last_visit)
    end

    it "should create a visit on first log" do
      Activity.log u, school_id, "Flying", time
      u.reload
      visit = u.last_visit
      expect(visit.seconds).to eq(30)
      expect(visit.start_activity).to eq(u.last_activity)
      expect(visit.stop_activity).to eq(u.last_activity)
    end

    it "should add to it as long as interval < visit::INTERVAL" do
      start = now = Time.now - 1.day

      # allow(Time).to receive(:now).and_return(now)
      one = Activity.log u, school_id, "one", now
      compare u.reload.last_visit, start_at: now,
                                   stop_at: now,
                                   seconds: 30,
                                   start_activity: one,
                                   stop_activity: one

      now += 40.seconds
      # allow(Time).to receive(:now).and_return(now + 40.seconds)
      two = Activity.log u, school_id, "two", now
      compare u.reload.last_visit,
              start_at: start,
              stop_at: now,
              seconds: 30 + 40,
              start_activity: one,
              stop_activity: two

      now += 55.seconds
      # allow(Time).to receive(:now).and_return(now + 40.seconds + 55.seconds)
      three = Activity.log u, school_id, "three", now
      compare u.reload.last_visit, start_at: start,
                                   stop_at: now,
                                   seconds: 30 + 40 + 55,
                                   start_activity: one,
                                   stop_activity: three
    end

    it "should create a new visit if interval > visit::INTERVAL" do
      now = Time.now - 1.day

      # allow(Time).to receive(:now).and_return(now)
      one = Activity.log u, school_id, "one", now
      compare u.reload.last_visit, start_at: now,
                                   stop_at: now,
                                   seconds: 30,
                                   start_activity: one,
                                   stop_activity: one

      later = now + Visit::INTERVAL + 31.second
      # allow(Time).to receive(:now).and_return(later)
      two = Activity.log u, school_id, "two", later
      compare u.reload.last_visit, start_at: later,
                                   stop_at: later,
                                   seconds: 30,
                                   start_activity: two,
                                   stop_activity: two
    end

    def zero_seconds(hash)
      hash.map { |k, v| [k, v.respond_to?(:change) ? v.change(sec: 0) : v] }.to_h
    end

    def compare(obj, expected)
      actual = zero_seconds(expected.map { |k, v| [k, obj.send(k)] })
      expect(actual).to eq(zero_seconds(expected))
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
