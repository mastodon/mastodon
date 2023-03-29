# frozen_string_literal: true

class Api::V1::Statuses::PinsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  before_action :set_status

  def create
    StatusPin.create!(account: current_account, status: @status)
    distribute_add_activity!
    return_source = params[:format] == "source" ? true : false
    render json: @status, serializer: REST::StatusSerializer, source_requested: return_source
  end

  def destroy
    pin = StatusPin.find_by(account: current_account, status: @status)

    if pin
      pin.destroy!
      distribute_remove_activity!
    end

    return_source = params[:format] == "source" ? true : false
    render json: @status, serializer: REST::StatusSerializer, source_requested: return_source
  end

  private

  def set_status
    @status = Status.find(params[:status_id])
  end

  def distribute_add_activity!
    json = ActiveModelSerializers::SerializableResource.new(
      @status,
      serializer: ActivityPub::AddSerializer,
      adapter: ActivityPub::Adapter
    ).as_json

    ActivityPub::RawDistributionWorker.perform_async(Oj.dump(json), current_account.id)
  end

  def distribute_remove_activity!
    json = ActiveModelSerializers::SerializableResource.new(
      @status,
      serializer: ActivityPub::RemoveSerializer,
      adapter: ActivityPub::Adapter
    ).as_json

    ActivityPub::RawDistributionWorker.perform_async(Oj.dump(json), current_account.id)
  end
end
