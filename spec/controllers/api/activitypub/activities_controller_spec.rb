require 'rails_helper'

RSpec.describe Api::Activitypub::ActivitiesController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }

  describe 'GET #show' do
    describe 'normal status' do
      public_status = nil

      before do
        public_status = Fabricate(:status, account: user.account, text: 'Hello world', visibility: :public)

        @request.env['HTTP_ACCEPT'] = 'application/activity+json'
        get :show_status, params: { id: public_status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets Content-Type header to AS2' do
        expect(response.header['Content-Type']).to include 'application/activity+json'
      end

      it 'returns http success' do
        json_data = JSON.parse(response.body)
        expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
        expect(json_data).to include('type' => 'Create')
        expect(json_data).to include('id' => @request.url)
        expect(json_data).to include('type' => 'Create')
        expect(json_data).to include('object' => api_activitypub_note_url(public_status))
        expect(json_data).to include('url' => TagManager.instance.url_for(public_status))
      end
    end

    describe 'reblog' do
      original = nil
      reblog = nil

      before do
        original = Fabricate(:status, account: user.account, text: 'Hello world', visibility: :public)
        reblog = Fabricate(:status, account: user.account, reblog_of_id: original.id, visibility: :public)

        @request.env['HTTP_ACCEPT'] = 'application/activity+json'
        get :show_status, params: { id: reblog.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets Content-Type header to AS2' do
        expect(response.header['Content-Type']).to include 'application/activity+json'
      end

      it 'returns http success' do
        json_data = JSON.parse(response.body)
        expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
        expect(json_data).to include('type' => 'Announce')
        expect(json_data).to include('id' => @request.url)
        expect(json_data).to include('type' => 'Announce')
        expect(json_data).to include('object' => api_activitypub_status_url(original))
        expect(json_data).to include('url' => TagManager.instance.url_for(reblog))
      end
    end
  end
end
