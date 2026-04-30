# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#cull' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#cull' do
    let(:action) { :cull }
    let(:delete_account_service) { instance_double(DeleteAccountService, call: nil) }
    let!(:tom)   { Fabricate(:account, updated_at: 30.days.ago, username: 'tom', uri: 'https://example.com/users/tom', domain: 'example.com', protocol: :activitypub) }
    let!(:bob)   { Fabricate(:account, updated_at: 30.days.ago, last_webfingered_at: nil, username: 'bob', uri: 'https://example.org/users/bob', domain: 'example.org', protocol: :activitypub) }
    let!(:gon)   { Fabricate(:account, updated_at: 15.days.ago, last_webfingered_at: 15.days.ago, username: 'gon', uri: 'https://example.net/users/gon', domain: 'example.net', protocol: :activitypub) }
    let!(:ana)   { Fabricate(:account, username: 'ana', uri: 'https://example.com/users/ana', domain: 'example.com', protocol: :activitypub) }
    let!(:tales) { Fabricate(:account, updated_at: 10.days.ago, last_webfingered_at: nil, username: 'tales', uri: 'https://example.net/users/tales', domain: 'example.net', protocol: :activitypub) }

    before do
      allow(DeleteAccountService).to receive(:new).and_return(delete_account_service)
    end

    context 'when no domain is specified' do
      before do
        stub_parallelize_with_progress!
        stub_request(:head, 'https://example.org/users/bob').to_return(status: 404)
        stub_request(:head, 'https://example.net/users/gon').to_return(status: 410)
        stub_request(:head, 'https://example.net/users/tales').to_return(status: 200)
      end

      def expect_delete_inactive_remote_accounts
        expect(delete_account_service).to have_received(:call).with(bob, reserve_username: false).once
        expect(delete_account_service).to have_received(:call).with(gon, reserve_username: false).once
      end

      def expect_not_delete_active_accounts
        expect(delete_account_service).to_not have_received(:call).with(tom, reserve_username: false)
        expect(delete_account_service).to_not have_received(:call).with(ana, reserve_username: false)
        expect(delete_account_service).to_not have_received(:call).with(tales, reserve_username: false)
      end

      it 'touches inactive remote accounts that have not been deleted and summarizes activity' do
        expect { subject }
          .to change { tales.reload.updated_at }
          .and output_results('Visited 5 accounts, removed 2')
        expect_delete_inactive_remote_accounts
        expect_not_delete_active_accounts
      end
    end

    context 'when a domain is specified' do
      let(:arguments) { ['example.net'] }

      before do
        stub_parallelize_with_progress!
        stub_request(:head, 'https://example.net/users/gon').to_return(status: 410)
        stub_request(:head, 'https://example.net/users/tales').to_return(status: 404)
      end

      def expect_delete_inactive_remote_accounts
        expect(delete_account_service).to have_received(:call).with(gon, reserve_username: false).once
        expect(delete_account_service).to have_received(:call).with(tales, reserve_username: false).once
      end

      it 'displays the summary correctly and deletes inactive remote accounts' do
        expect { subject }
          .to output_results('Visited 2 accounts, removed 2')
        expect_delete_inactive_remote_accounts
      end
    end

    context 'when a domain is unavailable' do
      shared_examples 'an unavailable domain' do
        before do
          stub_parallelize_with_progress!
          stub_request(:head, 'https://example.org/users/bob').to_return(status: 200)
          stub_request(:head, 'https://example.net/users/gon').to_return(status: 200)
        end

        def expect_skip_accounts_from_unavailable_domain
          expect(delete_account_service).to_not have_received(:call).with(tales, reserve_username: false)
        end

        it 'displays the summary correctly and skip accounts from unavailable domains' do
          expect { subject }
            .to output_results("Visited 5 accounts, removed 0\nThe following domains were not available during the check:\n    example.net")
          expect_skip_accounts_from_unavailable_domain
        end
      end

      context 'when a connection timeout occurs' do
        before do
          stub_request(:head, 'https://example.net/users/tales').to_timeout
        end

        it_behaves_like 'an unavailable domain'
      end

      context 'when a connection error occurs' do
        before do
          stub_request(:head, 'https://example.net/users/tales').to_raise(HTTP::ConnectionError)
        end

        it_behaves_like 'an unavailable domain'
      end

      context 'when an ssl error occurs' do
        before do
          stub_request(:head, 'https://example.net/users/tales').to_raise(OpenSSL::SSL::SSLError)
        end

        it_behaves_like 'an unavailable domain'
      end

      context 'when a private network address error occurs' do
        before do
          stub_request(:head, 'https://example.net/users/tales').to_raise(Mastodon::PrivateNetworkAddressError)
        end

        it_behaves_like 'an unavailable domain'
      end
    end
  end
end
