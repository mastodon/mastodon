# frozen_string_literal: true

class ActivityPub::DistributionWorker < ActivityPub::RawDistributionWorker
  # Distribute a new status or an edit of a status to all the places
  # where the status is supposed to go or where it was interacted with
  def perform(status_id, status_edit_id = nil)
    @status      = Status.find(status_id)
    @status_edit = @status.edits.find(status_edit_id) if status_edit_id.present?
    @account     = @status.account

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def inboxes
    @inboxes ||= StatusReachFinder.new(@status).inboxes
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(activity, ActivityPub::ActivitySerializer, signer: @account))
  end

  def activity
    if @status_edit
      ActivityPub::ActivityPresenter.from_status_edit(@status_edit)
    else
      ActivityPub::ActivityPresenter.from_status(@status)
    end
  end

  def options
    { synchronize_followers: !@status.distributable? }
  end
end
