# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tag' do
  let(:user) { Fabricate(:user) }
  let(:scopes)  { 'read:statuses' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/timelines/tag/:hashtag' do
    subject do
      get "/api/v1/timelines/tag/#{hashtag}", headers: headers, params: params
    end

    shared_examples 'a successful request to the tag timeline' do
      it 'returns the expected statuses', :aggregate_failures do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body.pluck(:id))
          .to match_array(expected_statuses.map { |status| status.id.to_s })
          .and not_include(private_status.id)
      end
    end

    let(:account)         { Fabricate(:account) }
    let!(:private_status) { PostStatusService.new.call(account, visibility: :private, text: '#life could be a dream') }
    let!(:life_status)    { PostStatusService.new.call(account, text: 'tell me what is my #life without your #love') }
    let!(:war_status)     { PostStatusService.new.call(user.account, text: '#war, war never changes') }
    let!(:love_status)    { PostStatusService.new.call(account, text: 'what is #love?') }
    let(:params)          { {} }
    let(:hashtag)         { 'life' }

    it_behaves_like 'forbidden for wrong scope', 'profile'

    context 'when given only one hashtag' do
      let(:expected_statuses) { [life_status] }

      it_behaves_like 'a successful request to the tag timeline'
    end

    context 'with any param' do
      let(:expected_statuses) { [life_status, love_status] }
      let(:params)            { { any: %(love) } }

      it_behaves_like 'a successful request to the tag timeline'
    end

    context 'with all param' do
      let(:expected_statuses) { [life_status] }
      let(:params)            { { all: %w(love) } }

      it_behaves_like 'a successful request to the tag timeline'
    end

    context 'with none param' do
      let(:expected_statuses) { [war_status] }
      let(:hashtag)           { 'war' }
      let(:params)            { { none: %w(life love) } }

      it_behaves_like 'a successful request to the tag timeline'
    end

    context 'with limit param' do
      let(:hashtag) { 'love' }
      let(:params)  { { limit: 1 } }

      it 'returns only the requested number of statuses' do
        subject

        expect(response.parsed_body.size).to eq(params[:limit])
      end

      it 'sets the correct pagination headers', :aggregate_failures do
        subject

        expect(response)
          .to include_pagination_headers(
            prev: api_v1_timelines_tag_url(limit: params[:limit], min_id: love_status.id),
            next: api_v1_timelines_tag_url(limit: params[:limit], max_id: love_status.id)
          )
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the instance allows public preview' do
      context 'when the user is not authenticated' do
        let(:headers) { {} }
        let(:expected_statuses) { [life_status] }

        it_behaves_like 'a successful request to the tag timeline'
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

      context 'when the user is authenticated' do
        let(:expected_statuses) { [life_status] }

        it_behaves_like 'a successful request to the tag timeline'
      end
    end
  end
end
