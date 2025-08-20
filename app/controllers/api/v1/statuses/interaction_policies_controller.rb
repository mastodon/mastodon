# frozen_string_literal: true

class Api::V1::Statuses::InteractionPoliciesController < Api::V1::Statuses::BaseController
  include Api::InteractionPoliciesConcern

  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }
  before_action -> { check_feature_enabled }

  def update
    authorize @status, :update?

    @status.update!(quote_approval_policy: quote_approval_policy)

    broadcast_updates! if @status.quote_approval_policy_previously_changed?

    render json: @status, serializer: REST::StatusSerializer
  end

  private

  def status_params
    params.permit(:quote_approval_policy)
  end

  def check_feature_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.outgoing_quotes_enabled?
  end

  def broadcast_updates!
    DistributionWorker.perform_async(@status.id, { 'update' => true })
    ActivityPub::StatusUpdateDistributionWorker.perform_async(@status.id, { 'updated_at' => Time.now.utc.iso8601 })
  end
end
