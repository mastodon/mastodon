# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#unfollow' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#unfollow' do
    let(:action) { :unfollow }

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that no account with the given username was found' do
        expect { subject }
          .to raise_error(Thor::Error, 'No such account')
      end
    end

    context 'when the given username is found' do
      let!(:target_account)  { Fabricate(:account) }
      let!(:follower_chris)  { Fabricate(:account, username: 'chris', domain: nil) }
      let!(:follower_rambo)  { Fabricate(:account, username: 'rambo', domain: nil) }
      let!(:follower_ana)    { Fabricate(:account, username: 'ana', domain: nil) }
      let(:unfollow_service) { instance_double(UnfollowService, call: nil) }
      let(:arguments) { [target_account.username] }

      before do
        accounts = [follower_chris, follower_rambo, follower_ana]
        accounts.each { |account| account.follow!(target_account) }
        allow(UnfollowService).to receive(:new).and_return(unfollow_service)
        stub_parallelize_with_progress!
      end

      it 'displays a successful message and makes all local accounts unfollow the target account' do
        expect { subject }
          .to output_results('OK, unfollowed target from 3 accounts')
        expect(unfollow_service).to have_received(:call).with(follower_chris, target_account).once
        expect(unfollow_service).to have_received(:call).with(follower_rambo, target_account).once
        expect(unfollow_service).to have_received(:call).with(follower_ana, target_account).once
      end
    end
  end
end
