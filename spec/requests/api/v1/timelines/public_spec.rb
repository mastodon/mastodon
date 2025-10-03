# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:statuses' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  shared_examples 'a successful request to the public timeline' do
    it 'returns the expected statuses successfully', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body.pluck(:id)).to match_array(expected_statuses.map { |status| status.id.to_s })
    end
  end

  describe 'GET /api/v1/timelines/public' do
    subject do
      get '/api/v1/timelines/public', headers: headers, params: params
    end

    let!(:local_status)   { Fabricate(:status, account: Fabricate.build(:account, domain: nil)) }
    let!(:remote_status)  { Fabricate(:status, account: Fabricate.build(:account, domain: 'example.com')) }
    let!(:media_status)   { Fabricate(:status, media_attachments: [Fabricate.build(:media_attachment)]) }
    let(:params) { {} }

    before do
      Fabricate(:status, visibility: :private)
    end

    context 'when the instance allows public preview' do
      let(:expected_statuses) { [local_status, remote_status, media_status] }

      it_behaves_like 'forbidden for wrong scope', 'profile'

      context 'with an authorized user' do
        it_behaves_like 'a successful request to the public timeline'
      end

      context 'with an anonymous user' do
        let(:headers) { {} }

        it_behaves_like 'a successful request to the public timeline'
      end

      context 'with local param' do
        let(:params) { { local: true } }
        let(:expected_statuses) { [local_status, media_status] }

        it_behaves_like 'a successful request to the public timeline'
      end

      context 'with remote param' do
        let(:params) { { remote: true } }
        let(:expected_statuses) { [remote_status] }

        it_behaves_like 'a successful request to the public timeline'
      end

      context 'with local and remote params' do
        let(:params) { { local: true, remote: true } }
        let(:expected_statuses) { [local_status, remote_status, media_status] }

        it_behaves_like 'a successful request to the public timeline'
      end

      context 'with only_media param' do
        let(:params) { { only_media: true } }
        let(:expected_statuses) { [media_status] }

        it_behaves_like 'a successful request to the public timeline'
      end

      context 'with limit param' do
        let(:params) { { limit: 1 } }

        it 'returns only the requested number of statuses and sets pagination headers', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body.size).to eq(params[:limit])

          expect(response)
            .to include_pagination_headers(
              prev: api_v1_timelines_public_url(limit: params[:limit], min_id: media_status.id),
              next: api_v1_timelines_public_url(limit: params[:limit], max_id: media_status.id)
            )
        end
      end
    end

    context 'when the instance does not allow public preview' do
      before do
        Form::AdminSettings.new(local_live_feed_access: 'authenticated', remote_live_feed_access: 'authenticated').save
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

      context 'with an authenticated user' do
        let(:expected_statuses) { [local_status, remote_status, media_status] }

        it_behaves_like 'a successful request to the public timeline'
      end
    end
  end
end
