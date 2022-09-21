# frozen_string_literal: true

class RefollowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  def perform(target_account_id)
    target_account = Account.find(target_account_id)
    return unless target_account.activitypub?

    target_account.passive_relationships.where(account: Account.where(domain: nil)).includes(:account).reorder(nil).find_each do |follow|
      reblogs   = follow.show_reblogs?
      notify    = follow.notify?
      languages = follow.languages

      # Locally unfollow remote account
      follower = follow.account
      follower.unfollow!(target_account)

      # Schedule re-follow
      begin
        FollowService.new.call(follower, target_account, reblogs: reblogs, notify: notify, languages: languages, bypass_limit: true)
      rescue Mastodon::NotPermittedError, ActiveRecord::RecordNotFound, Mastodon::UnexpectedResponseError, HTTP::Error, OpenSSL::SSL::SSLError
        next
      end
    end
  end
end
