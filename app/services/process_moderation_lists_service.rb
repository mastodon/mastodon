# frozen_string_literal: true

class ProcessModerationListsService < BaseService
  Suggestion = Struct.new(:target_type, :target_key, :action, :moderation_subscription_id, :apply_automatically)
  Retraction = Struct.new(:target_type, :action, :moderation_subscription_id, :retract_automatically)

  def call
    applicable_actions = Rails.configuration.x.mastodon.limited_federation_mode ? ['accept'] : ['reject', 'limit']

    @retractions = {}

    ModerationSubscription.order(priority: :desc).each do |subscription|
      advisories = subscription.advisories.where(action: applicable_actions).to_a

      # TODO: optimize this
      advisories.delete_if { |advisory| SubscribedAdvisory.superseding_advisories(advisory).exists? }

      # 1. apply automatic suggestions, if possible/needed
      if subscription.apply_automatically
        if subscription.preserve_relationships
          domains_with_follows = Instance.with_domain_follows(advisories.filter_map { |advisory| advisory.target_key if advisory.target_type == 'domain' && advisory.action == 'reject' }).pluck(:domain)
        end

        advisories.delete_if do |advisory|
          next false if subscription.preserve_relationships && advisory.target_type == 'domain' && domains_with_follows.include?(advisory.target_key)
          next false if SubscribedAdvisory.conflicting_advisories(advisory).exists?

          apply_automatic_advisory!(advisory)
        end
      end

      # 2. upsert remaining suggestions
      ModerationSuggestion.upsert_all(
        advisories.map do |advisory|
          {
            target_type: advisory.target_type,
            target_key: advisory.target_key,
            action: advisory.action,
            moderation_subscription_id: subscription.id,
          }
        end,
        unique_by: [:target_type, :target_key, :action]
      )

      # 3. orphan suggestions
      advisories.group_by(&:target_type).each do |target_type, advisories|
        subscription
          .suggestions
          .where(target_type: target_type)
          .where.not(target_key: advisories.map(&:target_key))
          .update_all(moderation_subscription_id: nil)
      end

      # 4. retractions
      collect_retractions!(subscription)
    end

    # Cleanup: is it really it?
    ModerationSuggestion.where(moderation_subscription_id: nil).delete_all

    # Handle retractions
    handle_retractions!
  end

  private

  def collect_retractions!(subscription)
    DomainAllow.where(moderation_subscription_id: subscription.id).where.not(domain: subscription.advisories.domain_target_type.accept_action.pluck(:target_key)).find_each do |domain_allow|
      @retractions[domain_allow.domain] = Retraction.new(
        action: 'accept',
        target_type: 'domain',
        retract_automatically: subscription.retract_automatically,
        moderation_subscription_id: subscription.id
      )
    end

    DomainBlock.where(moderation_subscription_id: subscription.id).where.not(domain: subscription.advisories.domain_target_type.where(action: ['limit', 'reject']).pluck(:target_key)).find_each do |domain_block|
      next if domain_block.noop?

      action = begin
        case domain_block.severity
        when 'silence'
          'limit'
        when 'suspend'
          'reject'
        end
      end

      @retractions[domain_block.domain] = Retraction.new(
        action:,
        target_type: 'domain',
        retract_automatically: subscription.retract_automatically,
        moderation_subscription_id: subscription.id
      )
    end
  end

  def handle_retractions!
    representative = Account.representative

    @retractions.each do |domain, attributes|
      suggestion = ModerationSuggestion.find_by(target_type: attributes[:target_type], target_key: domain, action: attributes[:action])
      if suggestion
        # TODO: log
        domain_block = DomainBlock.find_by(domain: domain)
        domain_block&.update(moderation_subscription_id: suggestion.moderation_subscription_id)
        suggestion.destroy
      elsif attributes[:retract_automatically]
        domain_block = DomainBlock.find_by(domain: domain)
        representative.action_logs.create!(action: 'destroy', target: domain_block, moderation_subscription_id: domain_block.moderation_subscription_id)
        UnblockDomainService.new.call(domain_block)
      else
        # TODO: what about if there is another kind of suggestion for the same target?
        ModerationSuggestion.upsert(
          {
            target_type: attributes[:target_type],
            target_key: domain,
            action: 'retract',
            moderation_subscription_id: attributes[:moderation_subscription_id],
          },
          unique_by: [:target_type, :target_key, :action]
        )
      end
    end
  end

  def apply_automatic_advisory!(advisory)
    representative = Account.representative

    case [advisory.target_type, advisory.action]
    when ['domain', 'accept']
      # TODO: error handling
      domain_allow = DomainAllow.create!(domain: advisory.target_key, moderation_subscription_id: advisory.moderation_subscription_id)
      representative.action_logs.create!(action: 'create', target: domain_allow, moderation_subscription_id: domain_allow.moderation_subscription_id)
      true
    when ['domain', 'reject'], ['domain', 'limit']
      # TODO: error handling
      domain_block = DomainBlock.create!(domain: advisory.target_key, moderation_subscription_id: advisory.moderation_subscription_id, obfuscate: false, severity: advisory.action == 'reject' ? 'suspend' : 'limit')
      representative.action_logs.create!(action: 'create', target: domain_block, moderation_subscription_id: domain_block.moderation_subscription_id)
      DomainBlockWorker.perform_async(domain_block.id)
      true
    else
      false
    end
  end
end
