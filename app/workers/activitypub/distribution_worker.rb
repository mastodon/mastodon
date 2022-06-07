# frozen_string_literal: true

class ActivityPub::DistributionWorker < ActivityPub::RawDistributionWorker
  # Distribute a new status or an edit of a status to all the places
  # where the status is supposed to go or where it was interacted with
  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.account

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def deliver_to_parent!
    return if @status.conversation.inbox_url.blank?

    ActivityPub::DeliveryWorker.perform_async(payload, @account.id, @status.conversation.inbox_url)
  end

  def deliver_to_inboxes!
    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [payload, @account.id, inbox_url, { synchronize_followers: !@status.distributable? }]
    end
  end

  def inboxes
    @inboxes ||= StatusReachFinder.new(@status).inboxes
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(activity, ActivityPub::ActivitySerializer, signer: @account))
  end

  def activity
    ActivityPub::ActivityPresenter.from_status(@status)
  end

  def options
    { 'synchronize_followers' => @status.private_visibility? }
  end
end
