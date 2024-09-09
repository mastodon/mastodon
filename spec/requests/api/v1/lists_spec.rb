# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lists' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:lists write:lists' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/lists' do
    subject do
      get '/api/v1/lists', headers: headers
    end

    let!(:lists) do
      [
        Fabricate(:list, account: user.account, title: 'first list', replies_policy: :followed),
        Fabricate(:list, account: user.account, title: 'second list', replies_policy: :list),
        Fabricate(:list, account: user.account, title: 'third list', replies_policy: :none),
        Fabricate(:list, account: user.account, title: 'fourth list', exclusive: true),
      ]
    end

    let(:expected_response) do
      lists.map do |list|
        {
          id: list.id.to_s,
          title: list.title,
          replies_policy: list.replies_policy,
          exclusive: list.exclusive,
        }
      end
    end

    before do
      Fabricate(:list)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:lists'

    it 'returns the expected lists', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match_array(expected_response)
    end
  end

  describe 'GET /api/v1/lists/:id' do
    subject do
      get "/api/v1/lists/#{list.id}", headers: headers
    end

    let(:list) { Fabricate(:list, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'write write:lists'

    it 'returns the requested list correctly', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match({
        id: list.id.to_s,
        title: list.title,
        replies_policy: list.replies_policy,
        exclusive: list.exclusive,
      })
    end

    context 'when the list belongs to a different user' do
      let(:list) { Fabricate(:list) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end

    context 'when the list does not exist' do
      it 'returns http not found' do
        get '/api/v1/lists/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/lists' do
    subject do
      post '/api/v1/lists', headers: headers, params: params
    end

    let(:params) { { title: 'my list', replies_policy: 'none', exclusive: 'true' } }

    it_behaves_like 'forbidden for wrong scope', 'read read:lists'

    it 'returns the new list', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match(a_hash_including(title: 'my list', replies_policy: 'none', exclusive: true))
      expect(List.where(account: user.account).count).to eq(1)
    end

    context 'when a title is not given' do
      let(:params) { { title: '' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'when the given replies_policy is invalid' do
      let(:params) { { title: 'a list', replies_policy: 'whatever' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT /api/v1/lists/:id' do
    subject do
      put "/api/v1/lists/#{list.id}", headers: headers, params: params
    end

    let(:list)   { Fabricate(:list, account: user.account, title: 'my list') }
    let(:params) { { title: 'list', replies_policy: 'followed', exclusive: 'true' } }

    it_behaves_like 'forbidden for wrong scope', 'read read:lists'

    it 'returns the updated list and updates values', :aggregate_failures do
      expect { subject }
        .to change_list_title
        .and change_list_replies_policy
        .and change_list_exclusive

      expect(response).to have_http_status(200)
      list.reload

      expect(response.parsed_body).to match({
        id: list.id.to_s,
        title: list.title,
        replies_policy: list.replies_policy,
        exclusive: list.exclusive,
      })
    end

    def change_list_title
      change { list.reload.title }.from('my list').to('list')
    end

    def change_list_replies_policy
      change { list.reload.replies_policy }.from('list').to('followed')
    end

    def change_list_exclusive
      change { list.reload.exclusive }.from(false).to(true)
    end

    context 'when the list does not exist' do
      it 'returns http not found' do
        put '/api/v1/lists/-1', headers: headers, params: params

        expect(response).to have_http_status(404)
      end
    end

    context 'when the list belongs to another user' do
      let(:list) { Fabricate(:list) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /api/v1/lists/:id' do
    subject do
      delete "/api/v1/lists/#{list.id}", headers: headers
    end

    let(:list) { Fabricate(:list, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:lists'

    it 'deletes the list', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(List.where(id: list.id)).to_not exist
    end

    context 'when the list does not exist' do
      it 'returns http not found' do
        delete '/api/v1/lists/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end

    context 'when the list belongs to another user' do
      let(:list) { Fabricate(:list) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end
end
