require 'rails_helper'

RSpec.describe Api::V1::FollowsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'follow') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'POST #create' do
    before do
      stub_request(:get,  "https://quitter.no/.well-known/host-meta").to_return(request_fixture('.host-meta.txt'))
      stub_request(:get,  "https://quitter.no/.well-known/webfinger?resource=acct:gargron@quitter.no").to_return(request_fixture('webfinger.txt'))
      stub_request(:head, "https://quitter.no/api/statuses/user_timeline/7477.atom").to_return(:status => 405, :body => "", :headers => {})
      stub_request(:get,  "https://quitter.no/api/statuses/user_timeline/7477.atom").to_return(request_fixture('feed.txt'))
      stub_request(:get,  "https://quitter.no/avatar/7477-300-20160211190340.png").to_return(request_fixture('avatar.txt'))
      stub_request(:post, "https://quitter.no/main/push/hub").to_return(:status => 200, :body => "", :headers => {})
      stub_request(:post, "https://quitter.no/main/salmon/user/7477").to_return(:status => 200, :body => "", :headers => {})

      post :create, params: { uri: 'gargron@quitter.no' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'creates account for remote user' do
      expect(Account.find_by(username: 'gargron', domain: 'quitter.no')).to_not be_nil
    end

    it 'creates a follow relation between user and remote user' do
      expect(user.account.following?(Account.find_by(username: 'gargron', domain: 'quitter.no'))).to be true
    end

    it 'sends a salmon slap to the remote user' do
      expect(a_request(:post, "https://quitter.no/main/salmon/user/7477")).to have_been_made
    end

    it 'subscribes to remote hub' do
      expect(a_request(:post, "https://quitter.no/main/push/hub")).to have_been_made
    end
  end
end
