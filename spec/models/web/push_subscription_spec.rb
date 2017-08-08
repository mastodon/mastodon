require 'rails_helper'

RSpec.describe Web::PushSubscription, type: :model do
  let(:alerts) { { mention: true, reblog: false, follow: true, follow_request: false, favourite: true } }
  let(:payload_no_alerts) { Web::PushSubscription.new(id: 1, endpoint: 'a', key_p256dh: 'c', key_auth: 'd').as_payload }
  let(:payload_alerts) { Web::PushSubscription.new(id: 1, endpoint: 'a', key_p256dh: 'c', key_auth: 'd', data: { alerts: alerts }).as_payload }
  let(:push_subscription) { Web::PushSubscription.new(data: { alerts: alerts }) }

  describe '#as_payload' do
    it 'only returns id and endpoint' do
      expect(payload_no_alerts.keys).to eq [:id, :endpoint]
    end

    it 'returns alerts if set' do
      expect(payload_alerts.keys).to eq [:id, :endpoint, :alerts]
    end
  end

  describe '#pushable?' do
    it 'obeys alert settings' do
      expect(push_subscription.send(:pushable?, Notification.new(activity_type: 'Mention'))).to eq true
      expect(push_subscription.send(:pushable?, Notification.new(activity_type: 'Status'))).to eq false
      expect(push_subscription.send(:pushable?, Notification.new(activity_type: 'Follow'))).to eq true
      expect(push_subscription.send(:pushable?, Notification.new(activity_type: 'FollowRequest'))).to eq false
      expect(push_subscription.send(:pushable?, Notification.new(activity_type: 'Favourite'))).to eq true
    end
  end
end
