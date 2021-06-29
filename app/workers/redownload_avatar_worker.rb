# frozen_string_literal: true

class RedownloadAvatarWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 7

  def perform(id)
    account = Account.find(id)

    return if account.suspended? || DomainBlock.rule_for(account.domain)&.reject_media?
    return if account.avatar_remote_url.blank? || account.avatar_file_name.present?

    account.reset_avatar!
    account.save!
  rescue ActiveRecord::RecordNotFound
    # Do nothing
  rescue Mastodon::UnexpectedResponseError => e
    response = e.response

    if response_error_unsalvageable?(response)
      # Give up
    else
      raise e
    end
  end
end
