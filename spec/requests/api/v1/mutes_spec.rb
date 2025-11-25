# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mutes' do
  include_context 'with API authentication', oauth_scopes: 'read:mutes'

  describe 'GET /api/v1/mutes' do
    subject do
      get '/api/v1/mutes', headers: headers, params: params
    end

    let!(:mutes) { Fabricate.times(2, :mute, account: user.account) }
    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'write write:mutes'

    it 'returns http success with muted accounts' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      muted_accounts = mutes.map(&:target_account)
      expect(response.parsed_body.pluck(:id)).to match_array(muted_accounts.map { |account| account.id.to_s })
    end

    context 'with limit param' do
      let(:params) { { limit: 1 } }

      it 'returns only the requested number of muted accounts with pagination headers' do
        subject

        expect(response.parsed_body.size).to eq(params[:limit])
        expect(response.content_type)
          .to start_with('application/json')
        expect(response)
          .to include_pagination_headers(
            prev: api_v1_mutes_url(limit: params[:limit], since_id: mutes.last.id),
            next: api_v1_mutes_url(limit: params[:limit], max_id: mutes.last.id)
          )
      end
    end

    context 'with max_id param' do
      let(:params) { { max_id: mutes[1].id } }

      it 'queries mutes in range according to max_id', :aggregate_failures do
        subject

        expect(response.parsed_body)
          .to contain_exactly(include(id: mutes.first.target_account_id.to_s))
      end
    end

    context 'with since_id param' do
      let(:params) { { since_id: mutes[0].id } }

      it 'queries mutes in range according to since_id', :aggregate_failures do
        subject

        expect(response.parsed_body)
          .to contain_exactly(include(id: mutes[1].target_account_id.to_s))
      end
    end

    context 'without an authentication header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
