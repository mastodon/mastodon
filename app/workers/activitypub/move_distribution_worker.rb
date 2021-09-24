# frozen_string_literal: true

class ActivityPub::MoveDistributionWorker < ActivityPub::UpdateDistributionWorker
  # Distribute a move activity to all servers that might have a copy of the
  # account in question, including places that blocked the account, so that
  # they have a chance to re-block the new account too
  def perform(migration_id)
    @migration = AccountMigration.find(migration_id)
    @account   = @migration.account

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def inboxes
    @inboxes ||= AccountReachFinder.new(@account, with_blocking_accounts: true).inboxes
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(@migration, ActivityPub::MoveSerializer, signer: @account))
  end
end
