# frozen_string_literal: true

class Admin::ModerationSuggestionsController < Admin::BaseController
  before_action :check_feature_enabled
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

    case ApplyModerationSuggestion.new.call(@moderation_suggestion, confirm_downgrade: params[:confirm_downgrade], confirm: params[:confirm])
    when :applied
      redirect_to admin_moderation_suggestion_path, notice: I18n.t('admin.moderation_suggestions.applied_msg', target_key: @moderation_suggestion.target_key)
    when :unable_to_apply
      redirect_to admin_moderation_suggestions_path, alert: I18n.t('admin.moderation_suggestions.unable_to_apply_msg', target_key: @moderation_suggestion.target_key)
    when :retracted
      redirect_to admin_moderation_suggestions_path, notice: I18n.t('admin.moderation_suggestions.retracted_msg', target_key: @moderation_suggestion.target_key)
    when :downgrade_confirmation_required
      render :confirm_downgrade
    when :reject_confirmation_required
      render :confirm_reject
    end
  end

  private

  def set_moderation_suggestion_targets
    @moderation_suggestion_targets = ModerationSuggestion.pending_review.reorder([target_type: :asc, target_key: :asc]).distinct.pluck(:target_type, :target_key)
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
      @moderation_suggestion_targets.group_by(&:first).reduce(ModerationSubscriptionAdvisory.none) do |scope, (target_type, target_pairs)|
        scope.or(ModerationSubscriptionAdvisory.joins(:moderation_subscription).where(target_type: target_type, target_key: target_pairs.map(&:second)))
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
        action = ModerationSubscription::DOMAIN_BLOCK_SEVERITY_TO_ACTION.fetch(domain_block.severity, 'accept')

        [['domain', domain_block.domain], action]
      end

      @current_state_by_target.default = 'accept'
    end
    @current_state_by_target
  end

  def set_moderation_suggestion
    @moderation_suggestion = ModerationSuggestion.find(params[:id])
  end

  def check_feature_enabled
    raise ActionController::RoutingError, 'Feature disabled' unless Mastodon::Feature.moderation_subscriptions_enabled?
  end
end
