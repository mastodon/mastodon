# frozen_string_literal: true

class UnfollowService < BaseService
  # Unfollow and notify the remote user
  # @param [Account] source_account Where to unfollow from
  # @param [Account] target_account Which to unfollow
  def call(source_account, target_account)
    follow = source_account.unfollow!(target_account)
    return unless follow
    NotificationWorker.perform_async(build_xml(follow), source_account.id, target_account.id) unless target_account.local?
    UnmergeWorker.perform_async(target_account.id, source_account.id)
  end

  private

  def build_xml(follow)
    AtomSerializer.render(AtomSerializer.new.unfollow_salmon(follow))
  end
end
