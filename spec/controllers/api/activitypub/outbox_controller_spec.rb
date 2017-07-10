require 'rails_helper'

RSpec.describe Api::ActivityPub::OutboxController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }

  describe 'GET #show' do
    before do
      @request.headers['ACCEPT'] = 'application/activity+json'
    end

    describe 'collection with small number of statuses' do
      public_status = nil

      before do
        public_status = Fabricate(:status, account: user.account, text: 'Hello world', visibility: :public)
        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :private)
        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :unlisted)
        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :direct)

        get :show, params: { id: user.account.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets Content-Type header to AS2' do
        expect(response.header['Content-Type']).to include 'application/activity+json'
      end

      it 'returns AS2 JSON body' do
        json_data = JSON.parse(response.body)
        expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
        expect(json_data).to include('id' => @request.url)
        expect(json_data).to include('type' => 'OrderedCollection')
        expect(json_data).to include('totalItems' => 1)
        expect(json_data).to include('current')
        expect(json_data).to include('first')
        expect(json_data).to include('last')
      end
    end

    describe 'collection with large number of statuses' do
      before do
        30.times do
          Fabricate(:status, account: user.account, text: 'Hello world', visibility: :public)
        end

        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :private)
        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :unlisted)
        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :direct)

        get :show, params: { id: user.account.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets Content-Type header to AS2' do
        expect(response.header['Content-Type']).to include 'application/activity+json'
      end

      it 'returns AS2 JSON body' do
        json_data = JSON.parse(response.body)
        expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
        expect(json_data).to include('id' => @request.url)
        expect(json_data).to include('type' => 'OrderedCollection')
        expect(json_data).to include('totalItems' => 30)
        expect(json_data).to include('current')
        expect(json_data).to include('first')
        expect(json_data).to include('last')
      end
    end

    describe 'page with small number of statuses' do
      statuses = []

      before do
        5.times do
          statuses << Fabricate(:status, account: user.account, text: 'Hello world', visibility: :public)
        end

        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :private)
        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :unlisted)
        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :direct)

        get :show, params: { id: user.account.id, max_id: statuses.last.id + 1 }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets Content-Type header to AS2' do
        expect(response.header['Content-Type']).to include 'application/activity+json'
      end

      it 'returns AS2 JSON body' do
        json_data = JSON.parse(response.body)
        expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
        expect(json_data).to include('id' => @request.url)
        expect(json_data).to include('type' => 'OrderedCollectionPage')
        expect(json_data).to include('partOf')
        expect(json_data).to include('items')
        expect(json_data['items'].length).to eq(5)
        expect(json_data).to include('prev')
        expect(json_data).to include('next')
        expect(json_data).to include('current')
        expect(json_data).to include('first')
        expect(json_data).to include('last')
      end
    end

    describe 'page with large number of statuses' do
      statuses = []

      before do
        30.times do
          statuses << Fabricate(:status, account: user.account, text: 'Hello world', visibility: :public)
        end

        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :private)
        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :unlisted)
        Fabricate(:status, account: user.account, text: 'Hello world', visibility: :direct)

        get :show, params: { id: user.account.id, max_id: statuses.last.id + 1 }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets Content-Type header to AS2' do
        expect(response.header['Content-Type']).to include 'application/activity+json'
      end

      it 'returns AS2 JSON body' do
        json_data = JSON.parse(response.body)
        expect(json_data).to include('@context' => 'https://www.w3.org/ns/activitystreams')
        expect(json_data).to include('id' => @request.url)
        expect(json_data).to include('type' => 'OrderedCollectionPage')
        expect(json_data).to include('partOf')
        expect(json_data).to include('items')
        expect(json_data['items'].length).to eq(20)
        expect(json_data).to include('prev')
        expect(json_data).to include('next')
        expect(json_data).to include('current')
        expect(json_data).to include('first')
        expect(json_data).to include('last')
      end
    end
  end
end
