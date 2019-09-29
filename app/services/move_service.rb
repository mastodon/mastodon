# frozen_string_literal: true

class MoveService < BaseService
  def call(migration)
    @migration      = migration
    @source_account = migration.account
    @target_account = migration.target_account

    update_redirect!
    process_local_relationships!
    distribute_update!
    distribute_move!
  end

  private

  def update_redirect!
    @source_account.update!(moved_to_account: @target_account)
  end

  def process_local_relationships!
    MoveWorker.perform_async(@source_account.id, @target_account.id)
  end

  def distribute_update!
    ActivityPub::UpdateDistributionWorker.perform_async(@source_account.id)
  end

  def distribute_move!
    ActivityPub::MoveDistributionWorker.perform_async(@migration.id)
  end
end
