require 'rails_helper'

RSpec.describe Api::Activitypub::OutboxController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }

  describe 'GET #show' do
    before do
      @request.env['HTTP_ACCEPT'] = 'application/activity+json'
    end

    describe 'small number of statuses' do
      public_status = nil

      before do
        public_status = Status.create!(account: user.account, text: 'Hello world', visibility: :public)
        Status.create!(account: user.account, text: 'Hello world', visibility: :private)
        Status.create!(account: user.account, text: 'Hello world', visibility: :unlisted)
        Status.create!(account: user.account, text: 'Hello world', visibility: :direct)

        get :show, params: { id: user.account.id }
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

      it 'returns AS2 JSON body' do
        json_data = JSON.parse(response.body)
        expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
        expect(json_data).to include('id' => @request.url)
        expect(json_data).to include('type' => 'OrderedCollection')
        expect(json_data).to include('totalItems' => 1)
        expect(json_data).to include('items')
        expect(json_data['items'].count).to eq(1)
        expect(json_data['items']).to include(api_activitypub_status_url(public_status))
      end
    end

    describe 'large number of statuses' do
      before do
        30.times do
          Status.create!(account: user.account, text: 'Hello world', visibility: :public)
        end

        Status.create!(account: user.account, text: 'Hello world', visibility: :private)
        Status.create!(account: user.account, text: 'Hello world', visibility: :unlisted)
        Status.create!(account: user.account, text: 'Hello world', visibility: :direct)
      end

      describe 'first page' do
        before do
          get :show, params: { id: user.account.id }
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

        it 'returns AS2 JSON body' do
          json_data = JSON.parse(response.body)
          expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
          expect(json_data).to include('id' => @request.url)
          expect(json_data).to include('type' => 'OrderedCollectionPage')
          expect(json_data).to include('totalItems' => 20)
          expect(json_data).to include('items')
          expect(json_data['items'].count).to eq(20)
          expect(json_data).to include('current' => @request.url)
          expect(json_data).to include('next')
          expect(json_data).to_not include('prev')
        end
      end
    end
  end
end
