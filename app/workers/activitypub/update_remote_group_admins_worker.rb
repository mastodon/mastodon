# frozen_string_literal: true

class ActivityPub::UpdateRemoteGroupAdminsWorker
  include Sidekiq::Worker

  def perform(group_id, uris)
    group = Group.find_by(id: group_id)
    return if group.nil?

    # Demote any group member that isn't listed anymore
    group.memberships.joins(:account).where(role: [:admin, :moderator]).where.not(account: { uri: uris }).update_all(role: :user)

    # Fetch accounts and promote them
    uris.each do |uri|
      account = ActivityPub::TagManager.instance.uri_to_resource(uri, Account)
      account ||= ActivityPub::FetchRemoteAccountService.new.call(uri)
      next if account.nil?

      membership = group.memberships.find_or_create_by(account: account)
      membership.role = :admin
      membership.save
    end
  end
end
