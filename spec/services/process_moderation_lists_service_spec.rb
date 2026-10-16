# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessModerationListsService do
  subject { described_class.new }

  describe '#call' do
    let(:high_priority_subscription) { Fabricate(:moderation_subscription, priority: 0, retract_automatically: false) }
    let(:intermediate_priority_subscription) { Fabricate(:moderation_subscription, priority: 10, list_action: :accept) }
    let(:subscription_with_automatic_application) { Fabricate(:moderation_subscription, priority: 20, apply_automatically: true, retract_automatically: true) }
    let(:subscription_with_unsafe_application) { Fabricate(:moderation_subscription, priority: 21, apply_automatically: true, preserve_relationships: false, retract_automatically: false) }
    let(:subscription_with_unattributed_override) { Fabricate(:moderation_subscription, priority: 22, apply_automatically: true, override_unattributed: true) }
    let(:low_priority_subscription) { Fabricate(:moderation_subscription, priority: 30, retract_automatically: true) }

    let(:local_account) { Fabricate(:account) }

    before do
      Fabricate(:domain_block, domain: 'retracted-block.com', moderation_subscription: high_priority_subscription, severity: :suspend)
      Fabricate(:domain_block, domain: 'retract-me.com', moderation_subscription: low_priority_subscription, severity: :suspend)
      Fabricate(:domain_block, domain: 'carried-over-block.com', moderation_subscription: subscription_with_automatic_application, severity: :suspend)
      Fabricate(:domain_block, domain: 'upgradable-block.com', moderation_subscription: subscription_with_automatic_application, severity: :silence)
      Fabricate(:domain_block, domain: 'prevented-automatic-block-upgrade.org', moderation_subscription: subscription_with_automatic_application, severity: :silence)
      Fabricate(:domain_block, domain: 'bypassed-automatic-block-upgrade.org', moderation_subscription: subscription_with_unsafe_application, severity: :silence)
      Fabricate(:domain_block, domain: 'downgrade-block.org', severity: :suspend)
      Fabricate(:domain_block, domain: 'unattributed-upgradable-block.org', severity: :silence)
      Fabricate(:domain_block, domain: 'second-unattributed-upgradable-block.org', severity: :silence)

      # Remote followed users that prevent automatic block creation
      %w(prevented-automatic-block.org prevented-automatic-block-upgrade.org bypassed-automatic-block.org bypassed-automatic-block-upgrade.org).each do |domain|
        local_account.follow!(Fabricate(:account, domain: domain))
      end

      %w(example.com).each do |domain|
        high_priority_subscription.advisories.create!(action: :reject, target_type: :domain, target_key: domain)
      end

      %w(automatic-block.org upgradable-block.com prevented-automatic-block.org prevented-automatic-block-upgrade.org).each do |domain|
        subscription_with_automatic_application.advisories.create!(action: :reject, target_type: :domain, target_key: domain)
      end

      %w(bypassed-automatic-block.org bypassed-automatic-block-upgrade.org unattributed-upgradable-block.org).each do |domain|
        subscription_with_unsafe_application.advisories.create!(action: :reject, target_type: :domain, target_key: domain)
      end

      subscription_with_unsafe_application.advisories.create!(action: :limit, target_type: :domain, target_key: 'downgrade-block.org')

      subscription_with_unattributed_override.advisories.create!(action: :reject, target_type: :domain, target_key: 'second-unattributed-upgradable-block.org')

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
        .and change { DomainBlock.find_by(domain: 'upgradable-block.com').severity }.from('silence').to('suspend')
        .and change { DomainBlock.find_by(domain: 'bypassed-automatic-block-upgrade.org').severity }.from('silence').to('suspend')
        .and change { DomainBlock.exists?(domain: 'retract-me.com') }.from(true).to(false)
        .and change { DomainBlock.exists?(domain: 'automatic-block.org') }.from(false).to(true)
        .and change { DomainBlock.exists?(domain: 'bypassed-automatic-block.org') }.from(false).to(true)
        .and change { DomainBlock.find_by(domain: 'carried-over-block.com').moderation_subscription_id }.from(subscription_with_automatic_application.id).to(low_priority_subscription.id)
        .and change { DomainBlock.find_by(domain: 'second-unattributed-upgradable-block.org').severity }.from('silence').to('suspend')
        .and(not_change { DomainBlock.find_by(domain: 'unattributed-upgradable-block.org').severity })
        .and(not_change { DomainBlock.find_by(domain: 'downgrade-block.org').severity })

      expect(Admin::ActionLog.pluck(:action, :target_type, :human_identifier, :moderation_subscription_id))
        .to contain_exactly(
          ['destroy', 'DomainBlock', 'retract-me.com', low_priority_subscription.id],
          ['create', 'DomainBlock', 'automatic-block.org', subscription_with_automatic_application.id],
          ['update', 'DomainBlock', 'upgradable-block.com', subscription_with_automatic_application.id],
          ['create', 'DomainBlock', 'bypassed-automatic-block.org', subscription_with_unsafe_application.id],
          ['update', 'DomainBlock', 'bypassed-automatic-block-upgrade.org', subscription_with_unsafe_application.id],
          ['update', 'DomainBlock', 'second-unattributed-upgradable-block.org', subscription_with_unattributed_override.id]
        )

      expect(ModerationSuggestion.pluck(:target_type, :target_key, :action, :moderation_subscription_id))
        .to contain_exactly(
          ['domain', 'example.com', 'reject', high_priority_subscription.id],
          ['domain', 'good.org', 'reject', low_priority_subscription.id],
          ['domain', 'evil.com', 'reject', low_priority_subscription.id],
          ['domain', 'retracted-block.com', 'retract', high_priority_subscription.id],
          ['domain', 'prevented-automatic-block.org', 'reject', subscription_with_automatic_application.id],
          ['domain', 'prevented-automatic-block-upgrade.org', 'reject', subscription_with_automatic_application.id],
          ['domain', 'downgrade-block.org', 'limit', subscription_with_unsafe_application.id],
          ['domain', 'unattributed-upgradable-block.org', 'reject', subscription_with_unsafe_application.id]
        )
    end
  end
end
