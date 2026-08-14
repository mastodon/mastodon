# frozen_string_literal: true

class ProcessModerationListsService < BaseService
  Suggestion = Struct.new(:target_type, :target_key, :action, :moderation_subscription_id, :apply_automatically)
  Retraction = Struct.new(:target_type, :action, :moderation_subscription_id, :retract_automatically)

  def call
    @retractions = collect_retractions!
    @suggestions = collect_suggestions!

    handle_retractions!
    filter_suggestions!
    apply_automatic_suggestions!

    save_suggestions!
  end

  private

  def collect_suggestions!
    suggestions = {}

    ModerationSubscription.order(priority: :desc).each do |subscription|
      # Handle new advisories
      subscription.advisories.domain_target_type.find_each do |advisory|
        next if suggestions.key?(advisory.target_key)

        suggestions[advisory.target_key] = Suggestion.new(
          action: advisory.action,
          target_type: advisory.target_type,
          target_key: advisory.target_key,
          moderation_subscription_id: subscription.id,
          apply_automatically: subscription.apply_automatically
        )
      end
    end

    suggestions
  end

  def collect_retractions!
    retractions = {}

    ModerationSubscription.find_each do |subscription|
      DomainAllow.where(moderation_subscription_id: subscription.id).where.not(domain: subscription.advisories.domain_target_type.accept_action.pluck(:target_key)).find_each do |domain_allow|
        retractions[domain_allow.domain] = Retraction.new(
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

        retractions[domain_block.domain] = Retraction.new(
          action:,
          target_type: 'domain',
          retract_automatically: subscription.retract_automatically,
          moderation_subscription_id: subscription.id
        )
      end
    end

    retractions
  end

  def handle_retractions!
    @retractions.each do |domain, attributes|
      suggestion = @suggestions[domain]
      if suggestion && suggestion[:action] == attributes[:action]
        # TODO: log
        domain_block = DomainBlock.find_by(domain: domain)
        domain_block&.update(moderation_subscription_id: suggestion[:moderation_subscription_id])
        @suggestions.delete(domain)
      elsif attributes[:retract_automatically]
        # TODO: log
        domain_block = DomainBlock.find_by(domain: domain)
        UnblockDomainService.new.call(domain_block)
      else
        # TODO: what about if there is another kind of suggestion for the same target?
        @suggestions[domain] = Suggestion.new(
          target_type: attributes[:target_type],
          target_key: domain,
          action: 'retract',
          moderation_subscription_id: attributes[:moderation_subscription_id]
        )
      end
    end
  end

  def filter_suggestions!
    if Rails.configuration.x.mastodon.limited_federation_mode
      # Filter out any block suggestion, as this is just the default
      # TODO: consider them as retractions instead?
      @suggestions.delete_if { |_, suggestion| ['reject', 'limit'].include?(suggestion[:action]) }
    else
      # Filter out any allow suggestion, as it is just the default
      # TODO: consider them as retractions instead?
      @suggestions.delete_if { |_, suggestion| suggestion[:action] == 'accept' }
    end
  end

  def apply_automatic_suggestions!
    @suggestions.delete_if do |_, suggestion|
      next false unless suggestion[:apply_automatically]

      apply_automatic_suggestion!(suggestion)
    end
  end

  def apply_automatic_suggestion!(suggestion)
    case [suggestion[:target_type], suggestion[:action]]
    when ['domain', 'accept']
      # TODO: log
      # TODO: error handling
      DomainAllow.create!(domain: suggestion[:target_key], moderation_subscription_id: suggestion[:moderation_subscription_id])
      true
    when ['domain', 'reject'], ['domain', 'limit']
      # TODO: log
      # TODO: error handling
      domain_block = DomainBlock.create!(domain: suggestion[:target_key], moderation_subscription_id: suggestion[:moderation_subscription_id], obfuscate: false, severity: suggestion[:action] == 'reject' ? 'suspend' : 'limit')
      DomainBlockWorker.perform_async(domain_block.id)
      true
    else
      false
    end
  end

  def save_suggestions!
    # Remove irrelevant suggestions
    @suggestions.values.group_by { |suggestion| suggestion[:target_type] }.each do |target_type, suggestions|
      ModerationSuggestion.where(target_type: target_type).where.not(target_key: suggestions.pluck(:target_key)).delete_all
    end

    # Insert suggestions
    ModerationSuggestion.upsert_all(
      @suggestions.values.map { |suggestion| suggestion.to_h.without(:apply_automatically) },
      unique_by: [:target_type, :target_key],
      on_duplicate: Arel.sql('action = EXCLUDED.action, moderation_subscription_id = EXCLUDED.moderation_subscription_id, state = CASE WHEN moderation_suggestions.action = EXCLUDED.action THEN moderation_suggestions.state ELSE EXCLUDED.state END')
    )
  end
end
