# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#refresh' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#refresh' do
    let(:action) { :refresh }

    context 'with --all option' do
      let(:options) { { all: true } }
      let!(:local_account) { Fabricate(:account, domain: nil) }
      let(:remote_com_avatar_url) { 'https://example.host/avatar/com' }
      let(:remote_com_header_url) { 'https://example.host/header/com' }
      let(:remote_account_example_com) { Fabricate(:account, domain: 'example.com', avatar_remote_url: remote_com_avatar_url, header_remote_url: remote_com_header_url) }
      let(:remote_net_avatar_url) { 'https://example.host/avatar/net' }
      let(:remote_net_header_url) { 'https://example.host/header/net' }
      let(:account_example_net) { Fabricate(:account, domain: 'example.net', avatar_remote_url: remote_net_avatar_url, header_remote_url: remote_net_header_url) }
      let(:scope) { Account.remote }

      before do
        stub_parallelize_with_progress!

        stub_request(:get, remote_com_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, remote_com_header_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, remote_net_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, remote_net_header_url)
          .to_return request_fixture('avatar.txt')

        remote_account_example_com
          .update_column(:avatar_file_name, nil)
        account_example_net
          .update_column(:avatar_file_name, nil)
      end

      it 'refreshes the avatar and header for all remote accounts' do
        expect { subject }
          .to output_results('Refreshed 2 accounts')
          .and not_change(local_account, :updated_at)

        # One request from factory creation, one more from task
        expect(a_request(:get, remote_com_avatar_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, remote_com_header_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, remote_net_avatar_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, remote_net_header_url))
          .to have_been_made.at_least_times(2)
      end

      context 'with --dry-run option' do
        let(:options) { { all: true, dry_run: true } }

        it 'does not refresh the avatar or header for any account' do
          expect { subject }
            .to output_results('Refreshed 2 accounts')

          # One request from factory creation, none from task due to dry run
          expect(a_request(:get, remote_com_avatar_url))
            .to have_been_made.once
          expect(a_request(:get, remote_com_header_url))
            .to have_been_made.once
          expect(a_request(:get, remote_net_avatar_url))
            .to have_been_made.once
          expect(a_request(:get, remote_net_header_url))
            .to have_been_made.once
        end
      end
    end

    context 'with a list of accts' do
      let!(:account_example_com_a) { Fabricate(:account, domain: 'example.com') }
      let!(:account_example_com_b) { Fabricate(:account, domain: 'example.com') }
      let!(:account_example_net)   { Fabricate(:account, domain: 'example.net') }
      let(:arguments)              { [account_example_com_a.acct, account_example_com_b.acct] }

      before do
        # NOTE: `Account.find_remote` is stubbed so that `Account#reset_avatar!`
        # can be stubbed on the individual accounts.
        allow(Account).to receive(:find_remote).with(account_example_com_a.username, account_example_com_a.domain).and_return(account_example_com_a)
        allow(Account).to receive(:find_remote).with(account_example_com_b.username, account_example_com_b.domain).and_return(account_example_com_b)
        allow(Account).to receive(:find_remote).with(account_example_net.username, account_example_net.domain).and_return(account_example_net)
      end

      it 'resets the avatar for the specified accounts' do
        allow(account_example_com_a).to receive(:reset_avatar!)
        allow(account_example_com_b).to receive(:reset_avatar!)

        expect { subject }
          .to output_results('OK')

        expect(account_example_com_a).to have_received(:reset_avatar!).once
        expect(account_example_com_b).to have_received(:reset_avatar!).once
      end

      it 'does not reset the avatar for unspecified accounts' do
        allow(account_example_net).to receive(:reset_avatar!)

        expect { subject }
          .to output_results('OK')

        expect(account_example_net).to_not have_received(:reset_avatar!)
      end

      it 'resets the header for the specified accounts' do
        allow(account_example_com_a).to receive(:reset_header!)
        allow(account_example_com_b).to receive(:reset_header!)

        expect { subject }
          .to output_results('OK')

        expect(account_example_com_a).to have_received(:reset_header!).once
        expect(account_example_com_b).to have_received(:reset_header!).once
      end

      it 'does not reset the header for unspecified accounts' do
        allow(account_example_net).to receive(:reset_header!)

        expect { subject }
          .to output_results('OK')

        expect(account_example_net).to_not have_received(:reset_header!)
      end

      context 'when an UnexpectedResponseError is raised' do
        it 'displays a failure message' do
          allow(account_example_com_a).to receive(:reset_avatar!).and_raise(Mastodon::UnexpectedResponseError)

          expect { subject }
            .to output_results("Account failed: #{account_example_com_a.username}@#{account_example_com_a.domain}")
        end
      end

      context 'when a specified account is not found' do
        it 'exits with an error message' do
          allow(Account).to receive(:find_remote).with(account_example_com_b.username, account_example_com_b.domain).and_return(nil)

          expect { subject }
            .to raise_error(Thor::Error, 'No such account')
        end
      end

      context 'with --dry-run option' do
        let(:options) { { dry_run: true } }

        it 'does not refresh the avatar for any account' do
          allow(account_example_com_a).to receive(:reset_avatar!)
          allow(account_example_com_b).to receive(:reset_avatar!)

          expect { subject }
            .to output_results('OK (DRY RUN)')

          expect(account_example_com_a).to_not have_received(:reset_avatar!)
          expect(account_example_com_b).to_not have_received(:reset_avatar!)
        end

        it 'does not refresh the header for any account' do
          allow(account_example_com_a).to receive(:reset_header!)
          allow(account_example_com_b).to receive(:reset_header!)

          expect { subject }
            .to output_results('OK (DRY RUN)')

          expect(account_example_com_a).to_not have_received(:reset_header!)
          expect(account_example_com_b).to_not have_received(:reset_header!)
        end
      end
    end

    context 'with --domain option' do
      let(:domain) { 'example.com' }
      let(:options) { { domain: domain } }

      let(:com_a_avatar_url) { 'https://example.host/avatar/a' }
      let(:com_a_header_url) { 'https://example.host/header/a' }
      let(:account_example_com_a) { Fabricate(:account, domain: domain, avatar_remote_url: com_a_avatar_url, header_remote_url: com_a_header_url) }

      let(:com_b_avatar_url) { 'https://example.host/avatar/b' }
      let(:com_b_header_url) { 'https://example.host/header/b' }
      let(:account_example_com_b) { Fabricate(:account, domain: domain, avatar_remote_url: com_b_avatar_url, header_remote_url: com_b_header_url) }

      let(:net_avatar_url) { 'https://example.host/avatar/net' }
      let(:net_header_url) { 'https://example.host/header/net' }
      let(:account_example_net) { Fabricate(:account, domain: 'example.net', avatar_remote_url: net_avatar_url, header_remote_url: net_header_url) }

      before do
        stub_parallelize_with_progress!

        stub_request(:get, com_a_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, com_a_header_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, com_b_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, com_b_header_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, net_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, net_header_url)
          .to_return request_fixture('avatar.txt')

        account_example_com_a
          .update_column(:avatar_file_name, nil)
        account_example_com_b
          .update_column(:avatar_file_name, nil)
        account_example_net
          .update_column(:avatar_file_name, nil)
      end

      it 'refreshes the avatar and header for all accounts on specified domain' do
        expect { subject }
          .to output_results('Refreshed 2 accounts')

        # One request from factory creation, one more from task
        expect(a_request(:get, com_a_avatar_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, com_a_header_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, com_b_avatar_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, com_b_header_url))
          .to have_been_made.at_least_times(2)

        # One request from factory creation, none from task
        expect(a_request(:get, net_avatar_url))
          .to have_been_made.once
        expect(a_request(:get, net_header_url))
          .to have_been_made.once
      end
    end

    context 'when neither a list of accts nor options are provided' do
      it 'exits with an error message' do
        expect { subject }
          .to raise_error(Thor::Error, 'No account(s) given')
      end
    end
  end
end
