# frozen_string_literal: true

class UnfollowService < BaseService
  # Unfollow and notify the remote user
  # @param [Account] source_account Where to unfollow from
  # @param [Account] target_account Which to unfollow
  def call(source_account, target_account)
    follow = source_account.unfollow!(target_account)
    return unless follow
    create_notification(follow) unless target_account.local?
    UnmergeWorker.perform_async(target_account.id, source_account.id)
    follow
  end

  private

  def create_notification(follow)
    if follow.target_account.ostatus?
      NotificationWorker.perform_async(build_xml(follow), follow.account_id, follow.target_account_id)
    elsif follow.target_account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(follow), follow.account_id, follow.target_account.inbox_url)
    end
  end

  def build_json(follow)
    Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(
      follow,
      serializer: ActivityPub::UndoFollowSerializer,
      adapter: ActivityPub::Adapter
    ).as_json).sign!(follow.account))
  end

  def build_xml(follow)
    OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.unfollow_salmon(follow))
  end
end
