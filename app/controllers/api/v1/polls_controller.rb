# frozen_string_literal: true

class Api::V1::PollsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, only: :show
  before_action :set_poll
  before_action :refresh_poll

  def show
    cache_if_unauthenticated!
    render json: @poll, serializer: REST::PollSerializer, include_results: true
  end

  private

  def set_poll
    @poll = Poll.find(params[:id])
    authorize @poll.status, :show?
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    not_found
  end

  def refresh_poll
    ActivityPub::FetchRemotePollService.new.call(@poll, current_account) if user_signed_in? && @poll.possibly_stale?
  end
end
