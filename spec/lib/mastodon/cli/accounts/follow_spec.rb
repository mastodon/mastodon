# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#follow' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#follow' do
    let(:action) { :follow }

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that no account with the given username was found' do
        expect { subject }
          .to raise_error(Thor::Error, 'No such account')
      end
    end

    context 'when the given username is found' do
      let!(:target_account)   { Fabricate(:account) }
      let!(:follower_bob)     { Fabricate(:account, username: 'bob') }
      let!(:follower_rony)    { Fabricate(:account, username: 'rony') }
      let!(:follower_charles) { Fabricate(:account, username: 'charles') }
      let(:follow_service)    { instance_double(FollowService, call: nil) }
      let(:arguments) { [target_account.username] }

      before do
        allow(FollowService).to receive(:new).and_return(follow_service)
        stub_parallelize_with_progress!
      end

      it 'displays a successful message and makes all local accounts follow the target account' do
        expect { subject }
          .to output_results("OK, followed target from #{Account.local.count} accounts")
        expect(follow_service).to have_received(:call).with(follower_bob, target_account, any_args).once
        expect(follow_service).to have_received(:call).with(follower_rony, target_account, any_args).once
        expect(follow_service).to have_received(:call).with(follower_charles, target_account, any_args).once
      end
    end
  end
end
