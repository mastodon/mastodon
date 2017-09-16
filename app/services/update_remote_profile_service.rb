# frozen_string_literal: true

class UpdateRemoteProfileService < BaseService
  include ProfileChangeNotifier

  attr_reader :account, :remote_profile

  def call(body, account, resubscribe = false)
    @account        = account
    @remote_profile = RemoteProfile.new(body)

    return if remote_profile.root.nil?

    update_account unless remote_profile.author.nil?

    old_hub_url     = account.hub_url
    account.hub_url = remote_profile.hub_link if remote_profile.hub_link.present? && remote_profile.hub_link != old_hub_url

    account.save_with_optional_media!

    notify_profile_change

    Pubsubhubbub::SubscribeWorker.perform_async(account.id) if resubscribe && account.hub_url != old_hub_url
  end

  private

  def update_account
    new_display_name     = remote_profile.display_name || ''
    account.note         = remote_profile.note         || ''
    account.locked       = remote_profile.locked?

    new_avatar_remote_url = account.avatar_remote_url

    if !account.suspended? && !DomainBlock.find_by(domain: account.domain)&.reject_media?
      new_avatar_remote_url = remote_profile.avatar.presence || ''

      if remote_profile.header.present?
        account.header_remote_url = remote_profile.header
      else
        account.header_remote_url = ''
        account.header.destroy
      end
    end

    if (account.avatar_remote_url || '') != new_avatar_remote_url || account.display_name != new_display_name
      prepare_profile_change(account)
    end

    account.avatar_remote_url = new_avatar_remote_url
    account.avatar.destroy if new_avatar_remote_url == ''
    account.display_name = new_display_name
  end
end
