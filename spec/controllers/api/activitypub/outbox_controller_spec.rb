require 'rails_helper'

RSpec.describe Api::Activitypub::OutboxController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }

  describe 'GET #show' do
    before do
      @request.headers['ACCEPT'] = 'application/activity+json'
    end

    describe 'collection with small number of statuses' do
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
    end

    describe 'page with large number of statuses' do
      statuses = []

      before do
        40.times do
          statuses << Status.create!(account: user.account, text: 'Hello world', visibility: :public)
        end

        Status.create!(account: user.account, text: 'Hello world', visibility: :private)
        Status.create!(account: user.account, text: 'Hello world', visibility: :unlisted)
        Status.create!(account: user.account, text: 'Hello world', visibility: :direct)
      end

      describe 'first page' do
        before do
          get :show, params: { id: user.account.id, max_id: statuses[30].id }
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
end
