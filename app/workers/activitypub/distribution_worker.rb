# frozen_string_literal: true

class ActivityPub::DistributionWorker < ActivityPub::RawDistributionWorker
  # Skip followers synchronization for accounts with a large number of followers,
  # as this is expensive and people with very large amounts of followers
  # necessarily have less control over them to begin with
  MAX_FOLLOWERS_FOR_SYNCHRONIZATION = 25_000

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

  def inboxes
    @inboxes ||= StatusReachFinder.new(@status).inboxes
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(@status, activity_serializer, serializer_options.merge(signer: @account)))
  end

  def activity_serializer
    @status.reblog? ? ActivityPub::AnnounceNoteSerializer : ActivityPub::CreateNoteSerializer
  end

  def serializer_options
    {}
  end

  def options
    { 'synchronize_followers' => @status.private_visibility? && @account.followers_count < MAX_FOLLOWERS_FOR_SYNCHRONIZATION }
  end
end
