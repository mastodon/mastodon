# frozen_string_literal: true

class Api::V1::Admin::StatusesController < Api::BaseController
  include Authorization
  include AccountableConcern

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:statuses' }, only: [:show]
  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:statuses' }, except: [:show]
  before_action :set_status

  after_action :verify_authorized

  def show
    authorize [:admin, @status], :show?
    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    authorize [:admin, @status], :destroy?
    ApplicationRecord.transaction do
      @status.discard_with_reblogs
      log_action :destroy, @status
      Tombstone.find_or_create_by(uri: @status.uri, account: @status.account, by_moderator: true)
    end
    json = render_to_body json: @status, serializer: REST::StatusSerializer, source_requested: true

    RemovalWorker.perform_async(@status.id, { 'preserve' => @status.account.local?, 'immediate' => !@status.account.local? })

    render json: json
  end

  def unsensitive
    authorize [:admin, @status], :update?
    representative_account = Account.representative
    ApplicationRecord.transaction do
      UpdateStatusService.new.call(@status, representative_account.id, sensitive: false) if @status.with_media?
      log_action :unsensitive, @status
    end
    render json: @status, serializer: REST::StatusSerializer
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end
end
