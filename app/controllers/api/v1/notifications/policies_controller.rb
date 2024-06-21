# frozen_string_literal: true

class Api::V1::Notifications::PoliciesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:notifications' }, only: :show
  before_action -> { doorkeeper_authorize! :write, :'write:notifications' }, only: :update

  before_action :require_user!
  before_action :set_policy

  def show
    render json: @policy, serializer: REST::NotificationPolicySerializer
  end

  def update
    @policy.update!(resource_params)
    render json: @policy, serializer: REST::NotificationPolicySerializer
  end

  private

  def set_policy
    @policy = NotificationPolicy.find_or_initialize_by(account: current_account)

    with_read_replica do
      @policy.summarize!
    end
  end

  def resource_params
    params.permit(
      :filter_not_following,
      :filter_not_followers,
      :filter_new_accounts,
      :filter_private_mentions
    )
  end
end
