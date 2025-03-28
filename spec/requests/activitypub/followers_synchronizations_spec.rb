# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivityPub Follower Synchronizations' do
  let!(:account) { Fabricate(:account) }
  let!(:follower_example_com_user_a) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/users/a') }
  let!(:follower_example_com_user_b) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/users/b') }
  let!(:follower_foo_com_user_a) { Fabricate(:account, domain: 'foo.com', uri: 'https://foo.com/users/a') }
  let!(:follower_example_com_instance_actor) { Fabricate(:account, username: 'instance-actor', domain: 'example.com', uri: 'https://example.com') }

  before do
    follower_example_com_user_a.follow!(account)
    follower_example_com_user_b.follow!(account)
    follower_foo_com_user_a.follow!(account)
    follower_example_com_instance_actor.follow!(account)
  end

  describe 'GET #show' do
    context 'without signature' do
      subject { get account_followers_synchronization_path(account_username: account.username) }

      it 'returns http not authorized' do
        subject

        expect(response)
          .to have_http_status(401)
      end
    end

    context 'with signature from example.com' do
      subject { get account_followers_synchronization_path(account_username: account.username), headers: nil, sign_with: remote_account }

      let(:remote_account) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/instance') }

      it 'returns http success and cache control and activity json types and correct items' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.headers['Cache-Control'])
          .to eq 'max-age=0, private'
        expect(response.media_type)
          .to eq 'application/activity+json'

        expect(response.parsed_body[:orderedItems])
          .to be_an(Array)
          .and contain_exactly(
            follower_example_com_instance_actor.uri,
            follower_example_com_user_a.uri,
            follower_example_com_user_b.uri
          )
      end

      context 'when account is permanently suspended' do
        before do
          account.suspend!
          account.deletion_request.destroy
        end

        it 'returns http gone' do
          subject

          expect(response)
            .to have_http_status(410)
        end
      end

      context 'when account is temporarily suspended' do
        before { account.suspend! }

        it 'returns http forbidden' do
          subject

          expect(response)
            .to have_http_status(403)
        end
      end
    end
  end
end
