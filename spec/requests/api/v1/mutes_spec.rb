# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mutes' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:mutes' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/mutes' do
    subject do
      get '/api/v1/mutes', headers: headers, params: params
    end

    let!(:mutes) { Fabricate.times(3, :mute, account: user.account) }
    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'write write:mutes'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns the muted accounts' do
      subject

      muted_accounts = mutes.map(&:target_account)

      expect(body_as_json.pluck(:id)).to match_array(muted_accounts.map { |account| account.id.to_s })
    end

    context 'with limit param' do
      let(:params) { { limit: 2 } }

      it 'returns only the requested number of muted accounts' do
        subject

        expect(body_as_json.size).to eq(params[:limit])
      end

      it 'sets the correct pagination headers', :aggregate_failures do
        subject

        headers = response.headers['Link']

        expect(headers.find_link(%w(rel prev)).href).to eq(api_v1_mutes_url(limit: params[:limit], since_id: mutes[2].id.to_s))
        expect(headers.find_link(%w(rel next)).href).to eq(api_v1_mutes_url(limit: params[:limit], max_id: mutes[1].id.to_s))
      end
    end

    context 'with max_id param' do
      let(:params) { { max_id: mutes[1].id } }

      it 'queries mutes in range according to max_id', :aggregate_failures do
        subject

        body = body_as_json

        expect(body.size).to eq 1
        expect(body[0][:id]).to eq mutes[0].target_account_id.to_s
      end
    end

    context 'with since_id param' do
      let(:params) { { since_id: mutes[0].id } }

      it 'queries mutes in range according to since_id', :aggregate_failures do
        subject

        body = body_as_json

        expect(body.size).to eq 2
        expect(body[0][:id]).to eq mutes[2].target_account_id.to_s
      end
    end

    context 'without an authentication header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end
  end
end
