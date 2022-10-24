# frozen_string_literal: true

class ActivityPub::GroupActivity::Delete < ActivityPub::Activity
  def perform
    if @account.uri == object_uri
      delete_group!
    else
      # TODO: should a group be able to `Delete` a post?
    end
  end

  private

  def delete_group!
    with_lock("delete_group_in_progress:#{@account.id}", autorelease: 2.hours, raise_on_failure: false) do
      DeleteGroupService.new.call(@account, keep_record: false, skip_activitypub: true)
    end
  end
end
