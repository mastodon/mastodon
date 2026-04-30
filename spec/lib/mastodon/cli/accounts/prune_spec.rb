# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#prune' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#prune' do
    let(:action) { :prune }
    let(:viable_attrs) { { domain: 'example.com', bot: false, suspended: false, silenced: false } }
    let!(:local_account) { Fabricate(:account) }
    let!(:bot_account) { Fabricate(:account, bot: true, domain: 'example.com') }
    let!(:group_account) { Fabricate(:account, actor_type: 'Group', domain: 'example.com') }
    let!(:account_mentioned) { Fabricate(:account, viable_attrs) }
    let!(:account_with_favourite) { Fabricate(:account, viable_attrs) }
    let!(:account_with_status) { Fabricate(:account, viable_attrs) }
    let!(:account_with_follow) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_follow) { Fabricate(:account, viable_attrs) }
    let!(:account_with_block) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_block) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_mute) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_report) { Fabricate(:account, viable_attrs) }
    let!(:account_with_follow_request) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_follow_request) { Fabricate(:account, viable_attrs) }
    let!(:prunable_accounts) { Fabricate.times(2, :account, viable_attrs) }

    before do
      Fabricate :mention, account: account_mentioned, status: Fabricate(:status, account: Fabricate(:account))
      Fabricate :favourite, account: account_with_favourite
      Fabricate :status, account: account_with_status
      Fabricate :follow, account: account_with_follow
      Fabricate :follow, target_account: account_targeted_follow
      Fabricate :block, account: account_with_block
      Fabricate :block, target_account: account_targeted_block
      Fabricate :mute, target_account: account_targeted_mute
      Fabricate :report, target_account: account_targeted_report
      Fabricate :follow_request, account: account_with_follow_request
      Fabricate :follow_request, target_account: account_targeted_follow_request
      stub_parallelize_with_progress!
    end

    it 'displays a successful message and handles accounts correctly' do
      expect { subject }
        .to output_results("OK, pruned #{prunable_accounts.size} accounts")
      expect(prunable_account_records)
        .to have_attributes(count: eq(0))
      expect(Account.all)
        .to include(local_account)
        .and include(bot_account)
        .and include(group_account)
        .and include(account_mentioned)
        .and include(account_with_favourite)
        .and include(account_with_status)
        .and include(account_with_follow)
        .and include(account_targeted_follow)
        .and include(account_with_block)
        .and include(account_targeted_block)
        .and include(account_targeted_mute)
        .and include(account_targeted_report)
        .and include(account_with_follow_request)
        .and include(account_targeted_follow_request)
        .and not_include(prunable_accounts.first)
        .and not_include(prunable_accounts.last)
    end

    def prunable_account_records
      Account.where(id: prunable_accounts.pluck(:id))
    end

    context 'with --dry-run option' do
      let(:options) { { dry_run: true } }

      def expect_no_account_prunes
        prunable_account_ids = prunable_accounts.pluck(:id)

        expect(Account.where(id: prunable_account_ids).count).to eq(prunable_accounts.size)
      end

      it 'displays a successful message with (DRY RUN) and doesnt prune anything' do
        expect { subject }
          .to output_results("OK, pruned #{prunable_accounts.size} accounts (DRY RUN)")
        expect_no_account_prunes
      end
    end
  end
end
