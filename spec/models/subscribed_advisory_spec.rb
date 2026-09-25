# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscribedAdvisory do
  describe 'by_subscription_priority' do
    let!(:high_priority) { Fabricate(:moderation_subscription, priority: 0) }
    let!(:low_priority) { Fabricate(:moderation_subscription, priority: 10) }
    let!(:med_priority) { Fabricate(:moderation_subscription, priority: 5) }

    before do
      Fabricate(:subscribed_advisory, target_type: :domain, target_key: 'example.com', moderation_subscription: med_priority)
      Fabricate(:subscribed_advisory, target_type: :domain, target_key: 'example.com', moderation_subscription: low_priority)
      Fabricate(:subscribed_advisory, target_type: :domain, target_key: 'example.com', moderation_subscription: high_priority)
    end

    it 'returns items in the expected order' do
      expect(described_class.by_subscription_priority.pluck(:moderation_subscription_id))
        .to eq [high_priority.id, med_priority.id, low_priority.id]
    end
  end
end
