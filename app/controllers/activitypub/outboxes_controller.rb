# frozen_string_literal: true

class ActivityPub::OutboxesController < Api::BaseController
  before_action :set_account

  def show
    @statuses = @account.statuses.permitted_for(@account, current_account).paginate_by_max_id(20, params[:max_id], params[:since_id])
    @statuses = cache_collection(@statuses, Status)

    render json: outbox_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def outbox_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_outbox_url(@account),
      type: :ordered,
      size: @account.statuses_count,
      items: @statuses
    )
  end
end
