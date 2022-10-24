# frozen_string_literal: true

class RedownloadHeaderWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 7

  def perform(actor_id, actor_type = 'Account')
    case actor_type
    when 'Account'
      actor = Account.find(actor_id)
    when 'Group'
      actor = Group.find(actor_id)
    else
      return
    end

    return if actor.suspended? || DomainBlock.rule_for(actor.domain)&.reject_media?
    return if actor.header_remote_url.blank? || actor.header_file_name.present?

    actor.reset_header!
    actor.save!
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
