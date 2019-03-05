# frozen_string_literal: true

class VoteService < BaseService
  include Authorization

  def call(account, poll, choices)
    authorize_with account, poll, :vote?

    @account = account
    @poll    = poll
    @choices = choices
    @votes   = []

    ApplicationRecord.transaction do
      @choices.each do |choice|
        @votes << @poll.votes.create!(account: @account, choice: choice)
      end
    end

    return if @poll.account.local?

    @votes.each do |vote|
      ActivityPub::DeliveryWorker.perform_async(
        build_json(vote),
        @account.id,
        @poll.account.inbox_url
      )
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
