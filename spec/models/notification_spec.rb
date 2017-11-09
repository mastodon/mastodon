require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe '#from_account' do
    pending
  end

  describe '#target_status' do
    before do
      allow(notification).to receive(:type).and_return(type)
      allow(notification).to receive(:activity).and_return(activity)
    end

    let(:notification) { Fabricate(:notification) }
    let(:status)       { instance_double('Status') }
    let(:favourite)    { instance_double('Favourite') }
    let(:mention)      { instance_double('Mention') }

    context 'type is :reblog' do
      let(:type)     { :reblog }
      let(:activity) { status }

      it 'calls activity.reblog' do
        expect(activity).to receive(:reblog)
        notification.target_status
      end
    end

    context 'type is :favourite' do
      let(:type)     { :favourite }
      let(:activity) { favourite }

      it 'calls activity.status' do
        expect(activity).to receive(:status)
        notification.target_status
      end
    end

    context 'type is :mention' do
      let(:type)     { :mention }
      let(:activity) { mention }

      it 'calls activity.status' do
        expect(activity).to receive(:status)
        notification.target_status
      end
    end
  end

  describe '#type' do
    it 'returns :reblog for a Status' do
      notification = Notification.new(activity: Status.new)
      expect(notification.type).to eq :reblog
    end

    it 'returns :mention for a Mention' do
      notification = Notification.new(activity: Mention.new)
      expect(notification.type).to eq :mention
    end

    it 'returns :favourite for a Favourite' do
      notification = Notification.new(activity: Favourite.new)
      expect(notification.type).to eq :favourite
    end

    it 'returns :follow for a Follow' do
      notification = Notification.new(activity: Follow.new)
      expect(notification.type).to eq :follow
    end
  end
end
