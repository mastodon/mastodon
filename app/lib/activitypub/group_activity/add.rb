# frozen_string_literal: true

class ActivityPub::GroupActivity::Add < ActivityPub::Activity
  def perform
    return if @json['target'].blank?

    case value_or_id(@json['target'])
    when @account.wall_url
      add_group_post!
    when @account.members_url
      add_group_member!
    end
  end

  private

  def add_group_post!
    if ActivityPub::TagManager.instance.local_uri?(object_uri)
      status = status_from_uri(object_uri)
      ApproveGroupStatusService.new.call(status) if status.present? && status.group_id == @account.id
    else
      # TODO: maybe optimize to handle same-origin embedded posts without additional fetches
      ActivityPub::FetchRemoteStatusService.new.call(object_uri, id: true, on_behalf_of: @account.members.local.first, expected_group: @account)
    end
  end

  def add_group_member!
    # TODO
  end
end
