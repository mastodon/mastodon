# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#migrate' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#migrate' do
    let(:action) { :migrate }
    let!(:source_account)         { Fabricate(:account) }
    let!(:target_account)         { Fabricate(:account, domain: 'example.com') }
    let(:arguments)               { [source_account.username] }
    let(:resolve_account_service) { instance_double(ResolveAccountService, call: nil) }
    let(:move_service)            { instance_double(MoveService, call: nil) }

    before do
      allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service)
      allow(MoveService).to receive(:new).and_return(move_service)
    end

    shared_examples 'a successful migration' do
      it 'displays a success message and calls the MoveService for the last migration' do
        expect { subject }
          .to output_results("OK, migrated #{source_account.acct} to #{target_account.acct}")

        expect(move_service)
          .to have_received(:call).with(last_migration).once
      end

      def last_migration
        source_account.migrations.last
      end
    end

    context 'when both --replay and --target options are given' do
      let(:options) { { replay: true, target: "#{target_account.username}@example.com" } }

      it 'exits with an error message indicating that using both options is not possible' do
        expect { subject }
          .to raise_error(Thor::Error, 'Use --replay or --target, not both')
      end
    end

    context 'when no option is given' do
      it 'exits with an error message indicating that at least one option must be used' do
        expect { subject }
          .to raise_error(Thor::Error, 'Use either --replay or --target')
      end
    end

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }
      let(:options) { { replay: true } }

      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to raise_error(Thor::Error, "No such account: #{arguments.first}")
      end
    end

    context 'with --replay option' do
      let(:options) { { replay: true } }

      context 'when the specified account has no previous migrations' do
        it 'exits with an error message indicating that the given account has no previous migrations' do
          expect { subject }
            .to raise_error(Thor::Error, 'The specified account has not performed any migration')
        end
      end

      context 'when the specified account has a previous migration' do
        before do
          allow(resolve_account_service).to receive(:call).with(source_account.acct, any_args).and_return(source_account)
          allow(resolve_account_service).to receive(:call).with(target_account.acct, any_args).and_return(target_account)
          target_account.aliases.create!(acct: source_account.acct)
          source_account.migrations.create!(acct: target_account.acct)
          source_account.update!(moved_to_account: target_account)
        end

        it_behaves_like 'a successful migration'

        context 'when the specified account is redirecting to a different target account' do
          before do
            source_account.update!(moved_to_account: nil)
          end

          it 'exits with an error message' do
            expect { subject }
              .to raise_error(Thor::Error, 'The specified account is not redirecting to its last migration target. Use --force if you want to replay the migration anyway')
          end
        end

        context 'with --force option' do
          let(:options) { { replay: true, force: true } }

          it_behaves_like 'a successful migration'
        end
      end
    end

    context 'with --target option' do
      let(:options) { { target: target_account.acct } }

      before do
        allow(resolve_account_service).to receive(:call).with(source_account.acct, any_args).and_return(source_account)
        allow(resolve_account_service).to receive(:call).with(target_account.acct, any_args).and_return(target_account)
      end

      context 'when the specified target account is not found' do
        before do
          allow(resolve_account_service).to receive(:call).with(target_account.acct).and_return(nil)
        end

        it 'exits with an error message indicating that there is no such account' do
          expect { subject }
            .to raise_error(Thor::Error, "The specified target account could not be found: #{options[:target]}")
        end
      end

      context 'when the specified target account exists' do
        before do
          target_account.aliases.create!(acct: source_account.acct)
        end

        it 'creates a migration for the specified account with the target account' do
          expect { subject }
            .to output_results('migrated')

          last_migration = source_account.migrations.last

          expect(last_migration.acct).to eq(target_account.acct)
        end

        it_behaves_like 'a successful migration'
      end

      context 'when the migration record is invalid' do
        it 'exits with an error indicating that the validation failed' do
          expect { subject }
            .to raise_error(Thor::Error, /Error: Validation failed/)
        end
      end

      context 'when the specified account is redirecting to a different target account' do
        before do
          source_account.update(moved_to_account: Fabricate(:account))
        end

        it 'exits with an error message' do
          expect { subject }
            .to raise_error(Thor::Error, 'The specified account is redirecting to a different target account. Use --force if you want to change the migration target')
        end
      end

      context 'with --target and --force options' do
        let(:options) { { target: target_account.acct, force: true } }

        before do
          source_account.update(moved_to_account: Fabricate(:account))
          target_account.aliases.create!(acct: source_account.acct)
        end

        it_behaves_like 'a successful migration'
      end
    end
  end
end
