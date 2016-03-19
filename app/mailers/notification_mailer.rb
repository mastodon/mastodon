class NotificationMailer < ApplicationMailer
  helper StreamEntriesHelper
  helper AtomBuilderHelper

  def mention(mentioned_account, status)
    @me     = mentioned_account
    @status = status

    mail to: @me.user.email, subject: "You were mentioned by #{@status.account.acct}"
  end

  def follow(followed_account, follower)
    @me      = followed_account
    @account = follower

    mail to: @me.user.email, subject: "#{@account.acct} is now following you"
  end

  def favourite(target_status, from_account)
    @me      = target_status.account
    @account = from_account
    @status  = target_status

    mail to: @me.user.email, subject: "#{@account.acct} favourited your status"
  end

  def reblog(target_status, from_account)
    @me      = target_status.account
    @account = from_account
    @status  = target_status

    mail to: @me.user.email, subject: "#{@account.acct} reblogged your status"
  end
end
