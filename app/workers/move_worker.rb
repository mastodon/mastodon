# frozen_string_literal: true

class MoveWorker
  include Sidekiq::Worker

  def perform(source_account_id, target_account_id)
    @source_account = Account.find(source_account_id)
    @target_account = Account.find(target_account_id)

    if @target_account.local? && @source_account.local?
      rewrite_follows!
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
    @source_account.passive_relationships
                   .where(account: Account.local)
                   .where.not(account: @target_account.followers.local)
                   .where.not(account_id: @target_account.id)
                   .in_batches
                   .update_all(target_account_id: @target_account.id)
  end

  def queue_follow_unfollows!
    bypass_locked = @target_account.local?

    @source_account.followers.local.select(:id).find_in_batches do |accounts|
      UnfollowFollowWorker.push_bulk(accounts.map(&:id)) { |follower_id| [follower_id, @source_account.id, @target_account.id, bypass_locked] }
    rescue => e
      @deferred_error = e
    end
  end

  def copy_account_notes!
    AccountNote.where(target_account: @source_account).find_each do |note|
      text = I18n.with_locale(note.account.user&.locale || I18n.default_locale) do
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
    unless AccountNote.where(account: account, target_account: @target_account).exists?
      text = I18n.with_locale(account.user&.locale || I18n.default_locale) do
        I18n.t(id, acct: @source_account.acct)
      end
      AccountNote.create!(account: account, target_account: @target_account, comment: text)
    end
  end
end
