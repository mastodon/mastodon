# frozen_string_literal: true

class Admin::ModerationSuggestionsController < Admin::BaseController
  before_action :set_moderation_suggestion_targets, only: :index
  before_action :set_moderation_suggestions_by_target, only: :index
  before_action :set_moderation_advisories_by_target, only: :index
  before_action :set_current_state_by_target, only: :index
  before_action :set_moderation_suggestion, only: [:destroy, :apply]

  def index
    authorize :moderation_suggestion, :index?
  end

  def destroy
    authorize @moderation_suggestion, :dismiss?

    # TODO: log?

    # Actually dismiss all of the suggestions for the same target
    ModerationSuggestion.where(target_type: @moderation_suggestion.target_type, target_key: @moderation_suggestion.target_key).update_all(state: :dismissed)

    redirect_to admin_moderation_suggestions_path, notice: I18n.t('admin.moderation_suggestions.destroyed_msg', target_key: @moderation_suggestion.target_key)
  end

  def apply
    authorize @moderation_suggestion, :apply?

    case [@moderation_suggestion.target_type, @moderation_suggestion.action]
    when ['domain', 'accept']
      domain_allow = @moderation_suggestion.to_domain_allow

      ApplicationRecord.transaction do
        # TODO: log
        domain_allow.save!
        @moderation_suggestion.mark_as_applied!
      end

      redirect_to admin_moderation_suggestions_path, notice: I18n.t('admin.moderation_suggestions.applied_msg', target_key: @moderation_suggestion.target_key)
    when ['domain', 'reject'], ['domain', 'limit']
      domain_block = @moderation_suggestion.to_domain_block

      # TODO: factor with `DomainBlocksController#create`?
      existing_domain_block = DomainBlock.rule_for(domain_block.domain)
      return redirect_to admin_moderation_suggestions_path, alert: I18n.t('admin.moderation_suggestions.unable_to_apply_msg', target_key: @moderation_suggestion.target_key) if existing_domain_block.present? && !domain_block.stricter_than?(existing_domain_block)

      # Allow transparently upgrading a domain block
      if existing_domain_block.present? && existing_domain_block.domain == TagManager.instance.normalize_domain(domain_block.domain)
        existing_domain_block.assign_attributes(domain_block.attributes.without('id', 'created_at', 'updated_at'))
        domain_block = existing_domain_block
      end

      # Require explicit confirmation on block
      return render :confirm_reject if requires_confirmation?(domain_block)

      # TODO: log
      domain_block.save!
      DomainBlockWorker.perform_async(domain_block.id)
      @moderation_suggestion.mark_as_applied!

      redirect_to admin_moderation_suggestions_path, notice: I18n.t('admin.moderation_suggestions.applied_msg', target_key: @moderation_suggestion.target_key)
    when ['domain', 'retract']
      ApplicationRecord.transaction do
        # TODO: log

        if Rails.configuration.x.mastodon.limited_federation_mode
          domain_allow = DomainAllow.find_by(domain: @moderation_suggestion.target_key)
          UnallowDomainService.new.call(domain_allow)
        else
          domain_block = DomainBlock.find_by(domain: @moderation_suggestion.target_key)
          UnblockDomainService.new.call(domain_block)
        end

        @moderation_suggestion.mark_as_applied!
      end

      redirect_to admin_moderation_suggestions_path, notice: I18n.t('admin.moderation_suggestions.retracted_msg', target_key: @moderation_suggestion.target_key)
    end
  end

  private

  def requires_confirmation?(domain_block)
    domain_block.valid? && (domain_block.new_record? || domain_block.severity_changed?) && domain_block.suspend? && !params[:confirm]
  end

  def set_moderation_suggestion_targets
    @moderation_suggestion_targets = ModerationSuggestion.where(state: ['new', 'mailed']).reorder([target_type: :asc, target_key: :asc]).distinct.pluck(:target_type, :target_key)
  end

  def set_moderation_suggestions_by_target
    @moderation_suggestions_by_target = begin
      @moderation_suggestion_targets.group_by(&:first).reduce(ModerationSuggestion.none) do |scope, (target_type, target_pairs)|
        scope.or(ModerationSuggestion.where(target_type: target_type, target_key: target_pairs.map(&:second)))
      end
    end.group_by { |suggestion| [suggestion.target_type, suggestion.target_key] }
  end

  def set_moderation_advisories_by_target
    @moderation_advisories_by_target = begin
      @moderation_suggestion_targets.group_by(&:first).reduce(SubscribedAdvisory.none) do |scope, (target_type, target_pairs)|
        scope.or(SubscribedAdvisory.joins(:moderation_subscription).where(target_type: target_type, target_key: target_pairs.map(&:second)))
      end
    end.group_by { |advisory| [advisory.target_type, advisory.target_key] }

    @moderation_advisories_by_target.each_value do |advisories|
      advisories.sort_by! { |advisory| advisory.moderation_subscription.priority }
    end

    @moderation_advisories_by_target
  end

  def set_current_state_by_target
    # TODO: handle other target types

    if Rails.configuration.x.mastodon.limited_federation_mode
      @current_state_by_target = DomainAllow.where(domain: @moderation_suggestion_targets.filter_map { |type, key| key if type == 'domain' }).pluck(:domain).to_h { |domain| [['domain', domain], 'accept'] }
      @current_state_by_target.default = 'reject'
    else
      @current_state_by_target = DomainBlock.where(domain: @moderation_suggestion_targets.filter_map { |type, key| key if type == 'domain' }).to_h do |domain_block|
        action = begin
          case domain_block.severity
          when 'suspend'
            'reject'
          when 'silence'
            'limit'
          else
            'accept'
          end
        end

        [['domain', domain_block.domain], action]
      end

      @current_state_by_target.default = 'accept'
    end
    @current_state_by_target
  end

  def set_moderation_suggestion
    @moderation_suggestion = ModerationSuggestion.find(params[:id])
  end
end
