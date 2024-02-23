# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveService do
  subject { described_class.new.call(migration) }

  context 'with a valid migration record' do
    let(:migration) { Fabricate(:account_migration, account: source_account, target_account: target_account) }
    let(:source_account) { Fabricate(:account) }
    let(:target_account) { Fabricate(:account, also_known_as: [source_account_uri]) }

    it 'migrates the account to a new account' do
      expect { subject }
        .to change_source_moved_value
        .and process_local_updates
        .and distribute_updates
        .and distribute_move
    end
  end

  def source_account_uri
    ActivityPub::TagManager
      .instance
      .uri_for(source_account)
  end

  def change_source_moved_value
    change(source_account.reload, :moved_to_account)
      .from(nil)
      .to(target_account)
  end

  def process_local_updates
    enqueue_sidekiq_job(MoveWorker)
      .with(source_account.id, target_account.id)
  end

  def distribute_updates
    enqueue_sidekiq_job(ActivityPub::UpdateDistributionWorker)
      .with(source_account.id)
  end

  def distribute_move
    enqueue_sidekiq_job(ActivityPub::MoveDistributionWorker)
      .with(migration.id)
  end
end
