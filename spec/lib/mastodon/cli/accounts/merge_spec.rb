# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#merge' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#merge' do
    let(:action) { :merge }

    shared_examples 'an account not found' do |acct|
      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to raise_error(Thor::Error, "No such account (#{acct})")
      end
    end

    context 'when "from_account" is not found' do
      let(:to_account) { Fabricate(:account, domain: 'example.com') }
      let(:arguments)  { ['non_existent_username@domain.com', "#{to_account.username}@#{to_account.domain}"] }

      it_behaves_like 'an account not found', 'non_existent_username@domain.com'
    end

    context 'when "from_account" is a local account' do
      let(:from_account) { Fabricate(:account, domain: nil, username: 'bob') }
      let(:to_account)   { Fabricate(:account, domain: 'example.com') }
      let(:arguments)    { [from_account.username, "#{to_account.username}@#{to_account.domain}"] }

      it_behaves_like 'an account not found', 'bob'
    end

    context 'when "to_account" is not found' do
      let(:from_account) { Fabricate(:account, domain: 'example.com') }
      let(:arguments)    { ["#{from_account.username}@#{from_account.domain}", 'non_existent_username'] }

      it_behaves_like 'an account not found', 'non_existent_username'
    end

    context 'when "to_account" is local' do
      let(:from_account) { Fabricate(:account, domain: 'example.com') }
      let(:to_account)   { Fabricate(:account, domain: nil, username: 'bob') }
      let(:arguments) do
        ["#{from_account.username}@#{from_account.domain}", "#{to_account.username}@#{to_account.domain}"]
      end

      it_behaves_like 'an account not found', 'bob@'
    end

    context 'when "from_account" and "to_account" public keys do not match' do
      let(:from_account) { instance_double(Account, username: 'bob', domain: 'example1.com', local?: false, public_key: 'from_account') }
      let(:to_account)   { instance_double(Account, username: 'bob', domain: 'example2.com', local?: false, public_key: 'to_account') }
      let(:arguments) do
        ["#{from_account.username}@#{from_account.domain}", "#{to_account.username}@#{to_account.domain}"]
      end

      before do
        allow(Account).to receive(:find_remote).with(from_account.username, from_account.domain).and_return(from_account)
        allow(Account).to receive(:find_remote).with(to_account.username, to_account.domain).and_return(to_account)
      end

      it 'exits with an error message indicating that the accounts do not have the same pub key' do
        expect { subject }
          .to raise_error(Thor::Error, "Accounts don't have the same public key, might not be duplicates!\nOverride with --force\n")
      end

      context 'with --force option' do
        let(:options) { { force: true } }

        before do
          allow(to_account).to receive(:merge_with!)
          allow(from_account).to receive(:destroy)
        end

        it 'merges `from_account` into `to_account` and deletes `from_account`' do
          expect { subject }
            .to output_results('OK')

          expect(to_account).to have_received(:merge_with!).with(from_account).once
          expect(from_account).to have_received(:destroy).once
        end
      end
    end

    context 'when "from_account" and "to_account" public keys match' do
      let(:from_account) { instance_double(Account, username: 'bob', domain: 'example1.com', local?: false, public_key: 'pub_key') }
      let(:to_account)   { instance_double(Account, username: 'bob', domain: 'example2.com', local?: false, public_key: 'pub_key') }
      let(:arguments) do
        ["#{from_account.username}@#{from_account.domain}", "#{to_account.username}@#{to_account.domain}"]
      end

      before do
        allow(Account).to receive(:find_remote).with(from_account.username, from_account.domain).and_return(from_account)
        allow(Account).to receive(:find_remote).with(to_account.username, to_account.domain).and_return(to_account)
        allow(to_account).to receive(:merge_with!)
        allow(from_account).to receive(:destroy)
      end

      it 'merges "from_account" into "to_account" and deletes from_account' do
        expect { subject }
          .to output_results('OK')

        expect(to_account).to have_received(:merge_with!).with(from_account).once
        expect(from_account).to have_received(:destroy)
      end
    end
  end
end
