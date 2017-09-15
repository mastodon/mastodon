# frozen_string_literal: true

class ActivityPub::OutboxesController < Api::BaseController
  before_action :set_account

  def show
    @statuses = Status.permitted_for(@account, current_account).paginate_by_max_id(20, params[:max_id], params[:since_id])

    render json: outbox_presenter, serializer: ActivityPub::OutboxSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def outbox_presenter
    ActivityPub::AccountCollectionPresenter.new account: @account, scope: @statuses
  end
end
