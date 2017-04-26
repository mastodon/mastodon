# frozen_string_literal: true

class MastodonTasksService
  def self.daily
    log_start_task('feeds::clear')
    Feeds.clear
    log_end_task('feeds::clear')

    log_start_task('media::clear')
    Media.clear
    log_end_task('media::clear')

    log_start_task('users::clear')
    Users.clear
    log_end_task('users::clear')

    log_start_task('push::refresh')
    Push.refresh
    log_end_task('push::refresh')
  end

  class Media
    class << self
      def clear
        MediaAttachment.where(status_id: nil).where('created_at < ?', 1.day.ago).find_each(&:destroy)
      end

      def remove_silenced
        MediaAttachment.where(account: Account.silenced).find_each(&:destroy)
      end

      def remove_remote
        MediaAttachment.where.not(remote_url: '').where('created_at < ?', 1.week.ago).find_each do |media|
          media.file.destroy
        end
      end
    end
  end

  class Push
    class << self
      def clear
        Account.remote.without_followers.where.not(subscription_expires_at: nil).find_each do |a|
          Rails.logger.debug "PuSH unsubscribing from #{a.acct}"
          UnsubscribeService.new.call(a)
        end
      end

      def refresh
        Account.expiring(1.day.from_now).find_each do |a|
          Rails.logger.debug "PuSH re-subscribing to #{a.acct}"
          SubscribeService.new.call(a)
        end
      end
    end
  end

  class Feeds
    class << self
      def clear
        User.confirmed.where('current_sign_in_at < ?', 14.days.ago).find_each do |user|
          Redis.current.del(FeedManager.instance.key(:home, user.account_id))
        end
      end

      def clear_all
        Redis.current.keys('feed:*').each { |key| Redis.current.del(key) }
      end
    end
  end

  class Users
    class << self
      def clear
        # Users that never confirmed e-mail never signed in, means they
        # only have a user record and an avatar record, with no files uploaded
        User.where('confirmed_at is NULL AND confirmation_sent_at <= ?', 2.days.ago).find_in_batches do |batch|
          Account.where(id: batch.map(&:account_id)).delete_all
          User.where(id: batch.map(&:id)).delete_all
        end
      end

      def admins
        log "Admin user emails:\n #{User.admins.map(&:email).join("\n")}"
      end
    end
  end

  def self.log_start_task(task)
    log "Starting #{task} at #{Time.now.utc}"
  end

  def self.log_end_task(task)
    log "Completing #{task} at #{Time.now.utc}"
  end

  def self.log(message)
    puts message
    Rails.logger.info message
  end
end
