# frozen_string_literal: true

class Api::V2::StatusesController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:statuses' }
  before_action :set_status

  def context
    descendants_results = @status.descendants(current_account, limit: 3, depth: 2, after_id: nil)
    @context = Context.new(ancestors: [], descendants: descendants_results)
    render json: @context, serializer: REST::ContextSerializer
  end

  private

  def set_status
    @status = Status.find(params[:id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
