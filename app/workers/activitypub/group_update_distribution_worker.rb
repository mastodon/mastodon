# frozen_string_literal: true

class ActivityPub::GroupUpdateDistributionWorker < ActivityPub::GroupRawDistributionWorker
  # Distribute a group profile update to servers that might have a copy
  # of the group in question
  def perform(group_id, options = {})
    @options = options.with_indifferent_access
    @group   = Group.find(group_id)

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def inboxes
    # TODO: possibly widen this
    @inboxes ||= @group.members.inboxes
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(@group, ActivityPub::UpdateSerializer, signer: @group, sign_with: @options[:sign_with]))
  end
end
