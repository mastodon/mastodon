# frozen_string_literal: true

require 'rails_helper'

describe RemoteUnfollowsController do
  render_views

  describe '#create' do
    subject { post :create, params: { acct: acct } }

    let(:current_user) { Fabricate(:user, account: current_account) }
    let(:current_account) { Fabricate(:account) }
    let(:remote_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox')).account }
    before do
      sign_in current_user
      current_account.follow!(remote_account)
      stub_request(:post, 'http://example.com/inbox') { { status: 200 } }
    end

    context 'when successfully unfollow remote account' do
      let(:acct) { "acct:#{remote_account.username}@#{remote_account.domain}" }

      it do
        is_expected.to render_template :success
        expect(current_account.following?(remote_account)).to be false
      end
    end

    context 'when fails to unfollow remote account' do
      let(:acct) { "acct:#{remote_account.username + '_test'}@#{remote_account.domain}" }

      it do
        is_expected.to render_template :error
        expect(current_account.following?(remote_account)).to be true
      end
    end
  end
end
