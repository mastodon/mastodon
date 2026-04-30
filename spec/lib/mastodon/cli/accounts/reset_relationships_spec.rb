# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#reset_relationships' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#reset_relationships' do
    let(:action) { :reset_relationships }
    let(:target_account) { Fabricate(:account) }
    let(:arguments)      { [target_account.username] }

    context 'when no option is given' do
      it 'exits with an error message indicating that at least one option is required' do
        expect { subject }
          .to raise_error(Thor::Error, 'Please specify either --follows or --followers, or both')
      end
    end

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }
      let(:options) { { follows: true } }

      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to raise_error(Thor::Error, 'No such account')
      end
    end

    context 'when the given username is found' do
      let(:total_relationships) { 3 }
      let!(:accounts)           { Fabricate.times(total_relationships, :account) }

      context 'with --follows option' do
        let(:options) { { follows: true } }

        before do
          accounts.each { |account| target_account.follow!(account) }
          allow(BootstrapTimelineWorker).to receive(:perform_async)
        end

        it 'resets following relationships and displays a successful message and rebuilds timeline' do
          expect { subject }
            .to output_results("Processed #{total_relationships} relationships")
          expect(target_account.reload.following).to be_empty
          expect(BootstrapTimelineWorker).to have_received(:perform_async).with(target_account.id).once
        end
      end

      context 'with --followers option' do
        let(:options) { { followers: true } }

        before do
          accounts.each { |account| account.follow!(target_account) }
        end

        it 'resets followers relationships and displays a successful message' do
          expect { subject }
            .to output_results("Processed #{total_relationships} relationships")
          expect(target_account.reload.followers).to be_empty
        end
      end

      context 'with --follows and --followers options' do
        let(:options) { { followers: true, follows: true } }

        before do
          accounts.first(2).each { |account| account.follow!(target_account) }
          accounts.last(1).each  { |account| target_account.follow!(account) }
          allow(BootstrapTimelineWorker).to receive(:perform_async)
        end

        it 'resets followers and following and displays a successful message and rebuilds timeline' do
          expect { subject }
            .to output_results("Processed #{total_relationships} relationships")
          expect(target_account.reload.followers).to be_empty
          expect(target_account.reload.following).to be_empty
          expect(BootstrapTimelineWorker).to have_received(:perform_async).with(target_account.id).once
        end
      end
    end
  end
end
