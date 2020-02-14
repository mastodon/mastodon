# frozen_string_literal: true

##
# Removes the +Mute+ of +target_account+ for +account+.
#
# Fans out by inserting a job to (re)fetch statuses and data for +target_account+
# into the +account+ feed.
#
# +account+ is the account removing the block.
# +target_account+ is the account being unblocked by +account+.
class UnmuteService < BaseService
  def call(account, target_account)
    return unless account.muting?(target_account)

    account.unmute!(target_account)

    MergeWorker.perform_async(target_account.id, account.id) if account.following?(target_account)
  end
end
