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

    copy_account_notes!
    carry_blocks_over!
    carry_mutes_over!
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
    end
  end


  def copy_account_notes!
    AccountNote.where(target_account: @source_account).find_each do |note|
      text = I18n.with_locale(note.account.user.locale || I18n.default_locale) do
        I18n.t('move_handler.copy_account_note_text', acct: @source_account.acct)
      end

      new_note = AccountNote.find_by(account: note.account, target_account: @target_account)
      if new_note.nil?
        AccountNote.create!(account: note.account, target_account: @target_account, comment: [text, note.comment].join('\n'))
      else
        new_note.update!(comment: [text, note.comment, '\n', new_note.comment].join('\n'))
      end
    end
  end

  def carry_blocks_over!
    @source_account.blocked_by_relationships.where(account: Account.local).find_each do |block|
      BlockService.new.call(block.account, @target_account) unless block.account.blocking?(@target_account) || block.account.following?(@target_account)
    end
  end

  def carry_mutes_over!
    @source_account.muted_by_relationships.where(account: Account.local).find_each do |mute|
      MuteService.new.call(mute.account, @target_account, notifications: mute.hide_notifications) unless mute.account.muting?(@target_account) || mute.account.following?(@target_account)
    end
  end
end
