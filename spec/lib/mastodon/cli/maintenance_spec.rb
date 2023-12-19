# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/maintenance'

describe Mastodon::CLI::Maintenance do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#fix_duplicates' do
    let(:action) { :fix_duplicates }

    context 'when the database version is too old' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2000_01_01_000000) # Earlier than minimum
      end

      it 'Exits with error message' do
        expect { subject }
          .to output_results('is too old')
          .and raise_error(SystemExit)
      end
    end

    context 'when the database version is too new and the user does not continue' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2100_01_01_000000) # Later than maximum
        allow(cli.shell).to receive(:yes?).with('Continue anyway? (Yes/No)').and_return(false).once
      end

      it 'Exits with error message' do
        expect { subject }
          .to output_results('more recent')
          .and raise_error(SystemExit)
      end
    end

    context 'when Sidekiq is running' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2022_01_01_000000) # Higher than minimum, lower than maximum
        allow(Sidekiq::ProcessSet).to receive(:new).and_return [:process]
      end

      it 'Exits with error message' do
        expect { subject }
          .to output_results('Sidekiq is running')
          .and raise_error(SystemExit)
      end
    end

    context 'when requirements are met' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2023_08_22_081029) # The latest migration before the cutoff
        agree_to_backup_warning
      end

      context 'with duplicate accounts' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_account_username) { 'username' }
        let(:duplicate_account_domain) { 'host.example' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating accounts',
              'Restoring index_accounts_on_username_and_domain_lower',
              'Reindexing textual indexes on accounts…',
              'Finished!'
            )
            .and change(duplicate_accounts, :count).from(2).to(1)
        end

        def duplicate_accounts
          Account.where(username: duplicate_account_username, domain: duplicate_account_domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :accounts, name: :index_accounts_on_username_and_domain_lower
          Fabricate(:account, username: duplicate_account_username, domain: duplicate_account_domain)
          Fabricate.build(:account, username: duplicate_account_username, domain: duplicate_account_domain).save(validate: false)
        end
      end

      context 'with duplicate users on email' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_email) { 'duplicate@example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating user records',
              'Restoring users indexes',
              'Finished!'
            )
            .and change(duplicate_users, :count).from(2).to(1)
        end

        def duplicate_users
          User.where(email: duplicate_email)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :users, :email
          Fabricate(:user, email: duplicate_email)
          Fabricate.build(:user, email: duplicate_email).save(validate: false)
        end
      end

      context 'with duplicate users on confirmation_token' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_confirmation_token) { '123ABC' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating user records',
              'Unsetting confirmation token',
              'Restoring users indexes',
              'Finished!'
            )
            .and change(duplicate_users, :count).from(2).to(1)
        end

        def duplicate_users
          User.where(confirmation_token: duplicate_confirmation_token)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :users, :confirmation_token
          Fabricate(:user, confirmation_token: duplicate_confirmation_token)
          Fabricate.build(:user, confirmation_token: duplicate_confirmation_token).save(validate: false)
        end
      end

      context 'with duplicate users on reset_password_token' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_reset_password_token) { '123ABC' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating user records',
              'Unsetting password reset token',
              'Restoring users indexes',
              'Finished!'
            )
            .and change(duplicate_users, :count).from(2).to(1)
        end

        def duplicate_users
          User.where(reset_password_token: duplicate_reset_password_token)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :users, :reset_password_token
          Fabricate(:user, reset_password_token: duplicate_reset_password_token)
          Fabricate.build(:user, reset_password_token: duplicate_reset_password_token).save(validate: false)
        end
      end

      def agree_to_backup_warning
        allow(cli.shell)
          .to receive(:yes?)
          .with('Continue? (Yes/No)')
          .and_return(true)
          .once
      end
    end
  end
end
