# frozen_string_literal: true

class ApplyModerationSuggestionService < BaseService
  include AccountableConcern

  def call(moderation_suggestion, confirm_downgrade: false, confirm: false)
    case [moderation_suggestion.target_type, moderation_suggestion.action]
    when ['domain', 'accept']
      apply_domain_accept!(moderation_suggestion)
    when ['domain', 'reject'], ['domain', 'limit']
      apply_domain_block!(moderation_suggestion, confirm_downgrade:, confirm:)
    when ['domain', 'retract']
      apply_domain_retraction!(moderation_suggestion)
    end
  end

  private

  def apply_domain_accept!(moderation_suggestion)
    domain_allow = moderation_suggestion.to_domain_allow

    ApplicationRecord.transaction do
      # TODO: log
      domain_allow.save!
      moderation_suggestion.mark_as_applied!
    end

    :applied
  end

  def apply_moderation_suggestion!(moderation_suggestion, confirm_downgrade: false, confirm: false)
    domain_block = moderation_suggestion.to_domain_block

    # TODO: factor with `DomainBlocksController#create`?
    existing_domain_block = DomainBlock.rule_for(domain_block.domain)

    # We can't create a laxer block for a subdomain than we have for a domain
    return :unable_to_apply if existing_domain_block.present? && existing_domain_block.domain != TagManager.instance.normalize_domain(domain_block.domain) && !domain_block.stricter_than?(existing_domain_block)

    update = false

    # Allow transparently upgrading a domain block
    if existing_domain_block.present? && existing_domain_block.domain == TagManager.instance.normalize_domain(domain_block.domain)
      # Downgrading requires confirmation
      return :downgrade_confirmation_required unless domain_block.stricter_than?(existing_domain_block) || confirm_downgrade

      # Transparent upgrading is allowed
      existing_domain_block.assign_attributes(domain_block.attributes.without('id', 'created_at', 'updated_at'))
      domain_block = existing_domain_block

      update = domain_block.severity_changed?
    end

    # Require explicit confirmation on block
    return :reject_confirmation_required if requires_confirmation?(domain_block) && !confirm

    domain_block.save!
    # TODO: is this the way we want to log it?
    log_action (update ? :update : :create), domain_block, moderation_subscription_id: domain_block.moderation_subscription_id
    DomainBlockWorker.perform_async(domain_block.id, update)
    moderation_suggestion.mark_as_applied!

    :applied
  end

  def apply_domain_retraction!(moderation_suggestion)
    ApplicationRecord.transaction do
      if Rails.configuration.x.mastodon.limited_federation_mode
        domain_allow = DomainAllow.find_by(domain: moderation_suggestion.target_key)
        UnallowDomainService.new.call(domain_allow)
        # TODO: is this the way we want to log it?
        log_action :destroy, domain_allow, moderation_subscription_id: domain_block.moderation_subscription_id
      else
        domain_block = DomainBlock.find_by(domain: moderation_suggestion.target_key)
        UnblockDomainService.new.call(domain_block)
        # TODO: is this the way we want to log it?
        log_action :destroy, domain_block, moderation_subscription_id: domain_block.moderation_subscription_id
      end

      mmoderation_suggestion.mark_as_applied!
    end

    :retracted
  end

  def requires_confirmation?(domain_block)
    domain_block.valid? && (domain_block.new_record? || domain_block.severity_changed?) && domain_block.suspend?
  end
end
