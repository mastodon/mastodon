# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Link' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:statuses' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  shared_examples 'a successful request to the link timeline' do
    it 'returns the expected statuses successfully', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body.pluck(:id)).to match_array(expected_statuses.map { |status| status.id.to_s })
    end
  end

  describe 'GET /api/v1/timelines/link' do
    subject do
      get '/api/v1/timelines/link', headers: headers, params: params
    end

    let(:url) { 'https://example.com/' }
    let(:private_status) { Fabricate(:status, visibility: :private) }
    let(:undiscoverable_status) { Fabricate(:status, account: Fabricate.build(:account, domain: nil, discoverable: false)) }
    let(:local_status) { Fabricate(:status, account: Fabricate.build(:account, domain: nil, discoverable: true)) }
    let(:remote_status) { Fabricate(:status, account: Fabricate.build(:account, domain: 'example.com', discoverable: true)) }
    let(:params) { { url: url } }
    let(:expected_statuses) { [local_status, remote_status] }
    let(:preview_card) { Fabricate(:preview_card, url: url) }

    before do
      if preview_card.present?
        preview_card.create_trend!(allowed: true)

        [private_status, undiscoverable_status, remote_status, local_status].each do |status|
          PreviewCardsStatus.create(status: status, preview_card: preview_card, url: url)
        end
      end
    end

    it_behaves_like 'forbidden for wrong scope', 'profile'

    context 'when there is no preview card' do
      let(:preview_card) { nil }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when preview card is not trending' do
      before do
        preview_card.trend.destroy!
      end

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when preview card is trending but not approved' do
      before do
        preview_card.trend.update(allowed: false)
      end

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the instance does not allow public preview' do
      before do
        Form::AdminSettings.new(timeline_preview: false).save
      end

      it_behaves_like 'forbidden for wrong scope', 'profile'

      context 'without an authentication token' do
        let(:headers) { {} }

        it 'returns http unprocessable entity' do
          subject

          expect(response).to have_http_status(422)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'with an application access token, not bound to a user' do
        let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil, scopes: scopes) }

        it 'returns http unprocessable entity' do
          subject

          expect(response).to have_http_status(422)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'when the user is authenticated' do
        it_behaves_like 'a successful request to the link timeline'
      end
    end

    context 'when the instance allows public preview' do
      context 'with an authorized user' do
        it_behaves_like 'a successful request to the link timeline'
      end

      context 'with an anonymous user' do
        let(:headers) { {} }

        it_behaves_like 'a successful request to the link timeline'
      end

      context 'with limit param' do
        let(:params) { { limit: 1, url: url } }

        it 'returns only the requested number of statuses with pagination headers', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body.size).to eq(params[:limit])

          expect(response)
            .to include_pagination_headers(
              prev: api_v1_timelines_link_url(limit: params[:limit], url: url, min_id: local_status.id),
              next: api_v1_timelines_link_url(limit: params[:limit], url: url, max_id: local_status.id)
            )
        end
      end
    end
  end
end
