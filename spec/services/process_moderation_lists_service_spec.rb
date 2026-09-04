# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessModerationListsService do
  subject { described_class.new }

  describe '#call' do
    let(:high_priority_subscription) { Fabricate(:moderation_subscription, priority: 0, retract_automatically: false) }
    let(:intermediate_priority_subscription) { Fabricate(:moderation_subscription, priority: 10, list_action: :accept) }
    let(:subscription_with_automatic_application) { Fabricate(:moderation_subscription, priority: 20, apply_automatically: true, retract_automatically: true) }
    let(:low_priority_subscription) { Fabricate(:moderation_subscription, priority: 30, retract_automatically: true) }

    before do
      Fabricate(:domain_block, domain: 'retracted-block.com', moderation_subscription: high_priority_subscription, severity: :suspend)
      Fabricate(:domain_block, domain: 'retract-me.com', moderation_subscription: low_priority_subscription, severity: :suspend)
      Fabricate(:domain_block, domain: 'carried-over-block.com', moderation_subscription: subscription_with_automatic_application, severity: :suspend)

      %w(example.com).each do |domain|
        high_priority_subscription.advisories.create!(action: :reject, target_type: :domain, target_key: domain)
      end

      %w(automatic-block.org).each do |domain|
        subscription_with_automatic_application.advisories.create!(action: :reject, target_type: :domain, target_key: domain)
      end

      %w(example.com good.org).each do |domain|
        intermediate_priority_subscription.advisories.create!(action: :accept, target_type: :domain, target_key: domain)
      end

      %w(example.com good.org evil.com carried-over-block.com).each do |domain|
        low_priority_subscription.advisories.create!(action: :reject, target_type: :domain, target_key: domain)
      end
    end

    it 'creates the epxected suggestions and audit log entries' do
      expect { subject.call }
        .to change(ModerationSuggestion, :count)
        .and change { DomainBlock.exists?(domain: 'retract-me.com') }.from(true).to(false)
        .and change { DomainBlock.exists?(domain: 'automatic-block.org') }.from(false).to(true)
        .and change { DomainBlock.find_by(domain: 'carried-over-block.com').moderation_subscription_id }.from(subscription_with_automatic_application.id).to(low_priority_subscription.id)

      expect(Admin::ActionLog.pluck(:action, :target_type, :human_identifier, :moderation_subscription_id))
        .to contain_exactly(
          ['destroy', 'DomainBlock', 'retract-me.com', low_priority_subscription.id],
          ['create', 'DomainBlock', 'automatic-block.org', subscription_with_automatic_application.id]
        )

      expect(ModerationSuggestion.pluck(:target_type, :target_key, :action, :moderation_subscription_id))
        .to contain_exactly(
          ['domain', 'example.com', 'reject', high_priority_subscription.id],
          ['domain', 'good.org', 'reject', low_priority_subscription.id],
          ['domain', 'evil.com', 'reject', low_priority_subscription.id],
          ['domain', 'retracted-block.com', 'retract', high_priority_subscription.id]
        )
    end
  end
end
