# frozen_string_literal: true

class MoveWorker
  include Sidekiq::Worker

  def perform(source_account_id, target_account_id)
    @source_account = Account.find(source_account_id)
    @target_account = Account.find(target_account_id)

    if @target_account.local? && @source_account.local?
      num_moved = rewrite_follows!
      @source_account.update_count!(:followers_count, -num_moved)
      @target_account.update_count!(:followers_count, num_moved)
    else
      queue_follow_unfollows!
    end

    @deferred_error = nil

    copy_account_notes!
    carry_blocks_over!
    carry_mutes_over!

    raise @deferred_error unless @deferred_error.nil?
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def rewrite_follows!
    num_moved = 0

    # First, approve pending follow requests for the new account,
    # this allows correctly processing list memberships with pending
    # follow requests
    FollowRequest.where(account: @source_account.followers, target_account_id: @target_account.id).find_each do |follow_request|
      ListAccount.where(follow_id: follow_request.id).includes(:list).find_each do |list_account|
        list_account.list.accounts << @target_account
      rescue ActiveRecord::RecordInvalid
        nil
      end

      follow_request.authorize!
    end

    # Then handle accounts that follow both the old and new account
    @source_account.passive_relationships
                   .where(account: Account.local)
                   .where(account: @target_account.followers.local)
                   .in_batches do |follows|
      ListAccount.where(follow: follows).includes(:list).find_each do |list_account|
        list_account.list.accounts << @target_account
      rescue ActiveRecord::RecordInvalid
        nil
      end
    end

    # Finally, handle the common case of accounts not following the new account
    @source_account.passive_relationships
                   .where(account: Account.local)
                   .where.not(account: @target_account.followers.local)
                   .where.not(account_id: @target_account.id)
                   .in_batches do |follows|
      ListAccount.where(follow: follows).in_batches.update_all(account_id: @target_account.id)
      num_moved += follows.update_all(target_account_id: @target_account.id)
    end

    num_moved
  end

  def queue_follow_unfollows!
    bypass_locked = @target_account.local?

    @source_account.followers.local.select(:id).reorder(nil).find_in_batches do |accounts|
      UnfollowFollowWorker.push_bulk(accounts.map(&:id)) { |follower_id| [follower_id, @source_account.id, @target_account.id, bypass_locked] }
    rescue => e
      @deferred_error = e
    end
  end

  def copy_account_notes!
    AccountNote.where(target_account: @source_account).find_each do |note|
      text = I18n.with_locale(note.account.user&.locale.presence || I18n.default_locale) do
        I18n.t('move_handler.copy_account_note_text', acct: @source_account.acct)
      end

      new_note = AccountNote.find_by(account: note.account, target_account: @target_account)
      if new_note.nil?
        begin
          AccountNote.create!(account: note.account, target_account: @target_account, comment: [text, note.comment].join("\n"))
        rescue ActiveRecord::RecordInvalid
          AccountNote.create!(account: note.account, target_account: @target_account, comment: note.comment)
        end
      else
        new_note.update!(comment: [text, note.comment, "\n", new_note.comment].join("\n"))
      end
    rescue ActiveRecord::RecordInvalid
      nil
    rescue => e
      @deferred_error = e
    end
  end

  def carry_blocks_over!
    @source_account.blocked_by_relationships.where(account: Account.local).find_each do |block|
      unless block.account.blocking?(@target_account) || block.account.following?(@target_account)
        BlockService.new.call(block.account, @target_account)
        add_account_note_if_needed!(block.account, 'move_handler.carry_blocks_over_text')
      end
    rescue => e
      @deferred_error = e
    end
  end

  def carry_mutes_over!
    @source_account.muted_by_relationships.where(account: Account.local).find_each do |mute|
      MuteService.new.call(mute.account, @target_account, notifications: mute.hide_notifications) unless mute.account.muting?(@target_account) || mute.account.following?(@target_account)
      add_account_note_if_needed!(mute.account, 'move_handler.carry_mutes_over_text')
    rescue => e
      @deferred_error = e
    end
  end

  def add_account_note_if_needed!(account, id)
    unless AccountNote.exists?(account: account, target_account: @target_account)
      text = I18n.with_locale(account.user&.locale.presence || I18n.default_locale) do
        I18n.t(id, acct: @source_account.acct)
      end
      AccountNote.create!(account: account, target_account: @target_account, comment: text)
    end
  end
end
