require 'rails_helper'

RSpec.describe Api::Activitypub::NotesController, type: :controller do
  render_views

  let(:user_alice)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:user_bob)  { Fabricate(:user, account: Fabricate(:account, username: 'bob')) }

  describe 'GET #show' do
    describe 'normal status' do
      public_status = nil

      before do
        public_status = Status.create!(account: user_alice.account, text: 'Hello world', visibility: :public)

        @request.env['HTTP_ACCEPT'] = 'application/activity+json'
        get :show, params: { id: public_status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets Content-Type header to AS2' do
        expect(response.header['Content-Type']).to include 'application/activity+json'
      end

      it 'sets Access-Control-Allow-Origin header to *' do
        expect(response.header['Access-Control-Allow-Origin']).to eq '*'
      end

      it 'returns http success' do
        json_data = JSON.parse(response.body)
        expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
        expect(json_data).to include('type' => 'Note')
        expect(json_data).to include('id' => @request.url)
        expect(json_data).to include('name' => 'Hello world')
        expect(json_data).to include('content' => 'Hello world')
        expect(json_data).to include('published')
        expect(json_data).to include('url' => TagManager.instance.url_for(public_status))
      end
    end

    describe 'reply' do
      original = nil
      reply = nil

      before do
        original = Status.create!(account: user_alice.account, text: 'Hello world', visibility: :public)
        reply = Status.create!(account: user_bob.account, text: 'Hello world', in_reply_to_id: original.id, visibility: :public)

        @request.env['HTTP_ACCEPT'] = 'application/activity+json'
        get :show, params: { id: reply.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets Content-Type header to AS2' do
        expect(response.header['Content-Type']).to include 'application/activity+json'
      end

      it 'sets Access-Control-Allow-Origin header to *' do
        expect(response.header['Access-Control-Allow-Origin']).to eq '*'
      end

      it 'returns http success' do
        json_data = JSON.parse(response.body)
        expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
        expect(json_data).to include('type' => 'Note')
        expect(json_data).to include('id' => @request.url)
        expect(json_data).to include('name' => 'Hello world')
        expect(json_data).to include('content' => 'Hello world')
        expect(json_data).to include('published')
        expect(json_data).to include('url' => TagManager.instance.url_for(reply))
        expect(json_data).to include('inReplyTo' => api_activitypub_note_url(original))
      end
    end
  end
end
