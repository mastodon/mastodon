require 'rails_helper'

RSpec.describe Api::SubscriptionsController, type: :controller do
  let(:account) { Fabricate(:account, username: 'gargron', domain: 'quitter.no', verify_token: '123', remote_url: 'topic_url', secret: 'abc') }

  describe 'GET #show' do
    before do
      get :show, :id => account.id, 'hub.topic' => 'topic_url', 'hub.verify_token' => 123, 'hub.challenge' => '456'
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
      stub_request(:get, "https://quitter.no/avatar/7477-300-20160211190340.png").to_return(request_fixture('avatar.txt'))

      request.env['HTTP_X_HUB_SIGNATURE'] = "sha1=#{OpenSSL::HMAC.hexdigest('sha1', 'abc', feed)}"
      request.env['RAW_POST_DATA'] = feed

      post :update, id: account.id
    end

    it 'returns http created' do
      expect(response).to have_http_status(:created)
    end

    it 'creates statuses for feed' do
      expect(account.statuses.count).to_not eq 0
    end
  end
end
