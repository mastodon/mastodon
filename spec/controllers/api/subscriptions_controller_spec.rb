require 'rails_helper'

RSpec.describe Api::SubscriptionsController, type: :controller do
  render_views

  let(:account) { Fabricate(:account, username: 'gargron', domain: 'quitter.no', remote_url: 'topic_url', secret: 'abc') }

  describe 'GET #show' do
    before do
      get :show, params: { :id => account.id, 'hub.topic' => 'topic_url', 'hub.challenge' => '456', 'hub.lease_seconds' => "#{86400 * 30}" }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'echoes back the challenge' do
      expect(response.body).to match '456'
    end
  end

  describe 'POST #update' do
    let(:feed) { File.read(File.join(Rails.root, 'spec', 'fixtures', 'push', 'feed.atom')) }

    before do
      stub_request(:post, "https://quitter.no/main/push/hub").to_return(:status => 200, :body => "", :headers => {})
      stub_request(:get, "https://quitter.no/avatar/7477-300-20160211190340.png").to_return(request_fixture('avatar.txt'))
      stub_request(:head, "https://quitter.no/notice/1269244").to_return(status: 404)
      stub_request(:head, "https://quitter.no/notice/1265331").to_return(status: 404)
      stub_request(:head, "https://community.highlandarrow.com/notice/54411").to_return(status: 404)
      stub_request(:head, "https://community.highlandarrow.com/notice/53857").to_return(status: 404)
      stub_request(:head, "https://community.highlandarrow.com/notice/51852").to_return(status: 404)
      stub_request(:head, "https://social.umeahackerspace.se/notice/424348").to_return(status: 404)
      stub_request(:head, "https://community.highlandarrow.com/notice/50467").to_return(status: 404)
      stub_request(:head, "https://quitter.no/notice/1243309").to_return(status: 404)
      stub_request(:head, "https://quitter.no/user/7477").to_return(status: 404)
      stub_request(:head, "https://community.highlandarrow.com/user/1").to_return(status: 404)
      stub_request(:head, "https://social.umeahackerspace.se/user/2").to_return(status: 404)
      stub_request(:head, "https://gs.kawa-kun.com/user/2").to_return(status: 404)
      stub_request(:head, "https://mastodon.social/users/Gargron").to_return(status: 404)

      request.env['HTTP_X_HUB_SIGNATURE'] = "sha1=#{OpenSSL::HMAC.hexdigest('sha1', 'abc', feed)}"
      request.env['RAW_POST_DATA'] = feed

      post :update, params: { id: account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'creates statuses for feed' do
      expect(account.statuses.count).to_not eq 0
    end
  end
end
