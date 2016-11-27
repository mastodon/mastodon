# frozen_string_literal: true

class Api::V1::MessagesController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!

  respond_to :json

  def index
    @messages = Message.where(account: current_account).paginate_by_max_id(20, params[:max_id], params[:since_id])
    @messages = cache(@messages)
    messages       = @messages #.select { |n| !n.target_status.nil? }.map(&:target_status)

    #set_maps(statuses)
    #set_counters_maps(statuses)
    #set_account_counters_maps(@notifications.map(&:from_account))

    next_path = api_v1_messages_url(max_id: @messages.last.id)    if @messages.size == 20
    prev_path = api_v1_messages_url(since_id: @messages.first.id) unless @messages.empty?

    set_pagination_headers(next_path, prev_path)
  end

  def create
  end
  
  def destroy
  end
end
