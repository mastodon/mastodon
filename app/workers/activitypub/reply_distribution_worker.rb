# frozen_string_literal: true

# Obsolete but kept around to make sure existing jobs do not fail after upgrade.
# Should be removed in a subsequent release.

class ActivityPub::ReplyDistributionWorker
  include Sidekiq::Worker
  include Payloadable

  sidekiq_options queue: 'push'

  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.thread&.account

    return unless @account.present? && @status.distributable?

    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [payload, @status.account_id, inbox_url]
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def inboxes
    @inboxes ||= @account.followers.inboxes
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(ActivityPub::ActivityPresenter.from_status(@status), ActivityPub::ActivitySerializer, signer: @status.account))
  end
end
