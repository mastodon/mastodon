# frozen_string_literal: true

class RedownloadHeaderWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 7

  def perform(id)
    account = Account.find(id)

    return if account.suspended? || DomainBlock.rule_for(account.domain)&.reject_media?
    return if account.header_remote_url.blank? || account.header_file_name.present?

    account.reset_header!
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
