# frozen_string_literal: true

class UnfollowService < BaseService
  # Unfollow and notify the remote user
  # @param [Account] source_account Where to unfollow from
  # @param [Account] target_account Which to unfollow
  def call(source_account, target_account)
    follow = source_account.unfollow!(target_account)
    NotificationWorker.perform_async(build_xml(follow), source_account.id, target_account.id) unless target_account.local?
    UnmergeWorker.perform_async(target_account.id, source_account.id)
  end

  private

  def build_xml(follow)
    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        title xml, "#{follow.account.acct} is no longer following #{follow.target_account.acct}"

        author(xml) do
          include_author xml, follow.account
        end

        object_type xml, :activity
        verb xml, :unfollow

        target(xml) do
          include_author xml, follow.target_account
        end
      end
    end.to_xml
  end
end
