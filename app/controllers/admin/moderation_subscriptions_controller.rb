# frozen_string_literal: true

class Admin::ModerationSubscriptionsController < Admin::BaseController
  before_action :set_moderation_subscriptions, only: :index
  before_action :set_moderation_subscription, only: [:show, :destroy]
  before_action :set_subscribed_advisories, only: :show

  def index
    authorize :moderation_subscription, :index?
  end

  def show
    authorize @moderation_subscription, :show?
  end

  def new
    authorize :moderation_subscription, :create?
    @moderation_subscription = ModerationSubscription.new
  end

  def create
    authorize :moderation_subscription, :create?

    # TODO: require confirmation for dangerous subscriptions

    @moderation_subscription = ModerationSubscription.new(resource_params.merge('type' => 'csv_list'))

    if @moderation_subscription.save
      log_action :create, @moderation_subscription
      redirect_to admin_moderation_subscriptions_path
    else
      render :new
    end
  end

  def destroy
    authorize @moderation_subscription, :destroy?

    ModerationSubscription.transaction do
      # Re-run moderation list service with empty list to ensure
      # Retractions are handled properly
      @moderation_subscription.advisories.delete_all
      ProcessModerationListsService.new.call

      @moderation_subscription.destroy!
      log_action :destroy, @moderation_subscription
    end

    redirect_to admin_moderation_subscriptions_path, notice: I18n.t('admin.moderation_subscriptions.destroyed_msg')
  end

  private

  def resource_params
    params.expect(
      moderation_subscription: [
        :name, :url, :priority, :list_action, :apply_conditions, :retract_automatically
      ]
    )
  end

  def set_moderation_subscriptions
    @moderation_subscriptions = ModerationSubscription.order(priority: :asc)
  end

  def set_moderation_subscription
    @moderation_subscription = ModerationSubscription.find(params[:id])
  end

  def set_subscribed_advisories
    @subscribed_advisories = @moderation_subscription.advisories.order(id: :asc).page(params[:page])
  end
end
