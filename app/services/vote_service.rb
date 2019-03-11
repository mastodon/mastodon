# frozen_string_literal: true

class VoteService < BaseService
  include Authorization

  def call(account, poll, choices)
    authorize_with account, poll, :vote?

    @account = account
    @poll    = poll
    @choices = choices
    @votes   = []

    return if @poll.expired?

    ApplicationRecord.transaction do
      @choices.each do |choice|
        @votes << @poll.votes.create!(account: @account, choice: choice)
      end
    end

    if @poll.account.local?
      ActivityPub::DistributePollUpdateWorker.perform_in(3.minutes, @poll.status.id) unless @poll.hide_totals
    else
      @votes.each do |vote|
        ActivityPub::DeliveryWorker.perform_async(
          build_json(vote),
          @account.id,
          @poll.account.inbox_url
        )
      end
      PollExpirationNotifyWorker.perform_at(@poll.expires_at + 5.minutes, @poll.id) unless @poll.expires_at.nil?
    end
  end

  private

  def build_json(vote)
    ActiveModelSerializers::SerializableResource.new(
      vote,
      serializer: ActivityPub::VoteSerializer,
      adapter: ActivityPub::Adapter
    ).to_json
  end
end
