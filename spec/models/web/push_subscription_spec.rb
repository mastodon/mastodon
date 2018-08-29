require 'rails_helper'

RSpec.describe Web::PushSubscription, type: :model do
  let(:alerts) { { mention: true, reblog: false, follow: true, follow_request: false, favourite: true } }
  let(:push_subscription) { Web::PushSubscription.new(data: { alerts: alerts }) }

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
