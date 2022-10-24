# frozen_string_literal: true

class ActivityPub::GroupActivity::Update < ActivityPub::Activity
  def perform
    dereference_object!

    update_group!
  end

  private

  def update_group!
    return reject_payload! if @account.uri != object_uri

    ActivityPub::ProcessGroupService.new.call(@object, signed_with_known_key: true)
  end
end
