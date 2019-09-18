require 'rails_helper'

describe ActivityCollection do
  subject(:activity_collection) { ActivityCollection.new }
  let(:first) { Activity.new(timestamp: 4.minutes.ago) }
  let(:second) { Activity.new(timestamp: 3.minutes.ago) }
  let(:third) { Activity.new(timestamp: 2.minutes.ago) }
  let(:fourth) { Activity.new(timestamp: 1.minutes.ago) }
  before do
    [third, fourth, first, second].each do |activity|
      activity_collection << activity
    end
  end

  describe "#most_recent" do
    subject(:most_recent) { activity_collection.most_recent }
    it { is_expected.to eql(fourth) }
  end

  describe "#first" do
    subject(:result) { activity_collection.first }
    it { is_expected.to eql(activity_collection.least_recent) }
  end

  describe "#last" do
    subject(:last) { activity_collection.last }
    it { is_expected.to eql(activity_collection.most_recent) }
  end

  describe "#least_recent" do
    subject(:least_recent) { activity_collection.least_recent }
    it { is_expected.to eql(first) }
  end

  describe "#<<" do
    it "Casts hashes to Activity objects" do
      activity_collection << { timestamp: 1.minute.ago }
      expect(activity_collection[0]).to be_kind_of(Activity)
    end

    it "Maintains the ordering by timestamp with the most recent at the start" do
      activity_collection = ActivityCollection.new

      activity_collection << second
      activity_collection << first
      activity_collection << third
      activity_collection << fourth

      aggregate_failures do
        expect(activity_collection[3]).to eql(first)
        expect(activity_collection[2]).to eql(second)
        expect(activity_collection[1]).to eql(third)
        expect(activity_collection[0]).to eql(fourth)
      end
    end
  end
end