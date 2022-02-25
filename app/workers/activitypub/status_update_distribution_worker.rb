# frozen_string_literal: true

class ActivityPub::StatusUpdateDistributionWorker < ActivityPub::DistributionWorker
  # Distribute an profile update to servers that might have a copy
  # of the account in question
  def perform(status_id, options = {})
    @options = options.with_indifferent_access
    @status  = Status.find(status_id)
    @account = @status.account

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def activity
    ActivityPub::ActivityPresenter.new(
      id: [ActivityPub::TagManager.instance.uri_for(@status), '#updates/', @status.edited_at.to_i].join,
      type: 'Update',
      actor: ActivityPub::TagManager.instance.uri_for(@status.account),
      published: @status.edited_at,
      to: ActivityPub::TagManager.instance.to(@status),
      cc: ActivityPub::TagManager.instance.cc(@status),
      virtual_object: @status
    )
  end
end
