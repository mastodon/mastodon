# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filters' do
  include_context 'with API authentication', oauth_scopes: 'read:filters write:filters'

  shared_examples 'unauthorized for invalid token' do
    let(:headers) { { 'Authorization' => '' } }

    it 'returns http unauthorized' do
      subject

      expect(response).to have_http_status(401)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end

  describe 'GET /api/v2/filters' do
    subject do
      get '/api/v2/filters', headers: headers
    end

    let!(:filters) { Fabricate.times(2, :custom_filter, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'write write:filters'
    it_behaves_like 'unauthorized for invalid token'

    it 'returns the existing filters successfully', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body.pluck(:id)).to match_array(filters.map { |filter| filter.id.to_s })
    end
  end

  describe 'POST /api/v2/filters' do
    subject do
      post '/api/v2/filters', params: params, headers: headers
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'read read:filters'
    it_behaves_like 'unauthorized for invalid token'

    context 'with valid params' do
      let(:params) { { title: 'magic', context: %w(home), filter_action: 'hide', keywords_attributes: [keyword: 'magic'] } }

      it 'returns http success with a filter with keywords in json and creates a filter', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to include(
            title: 'magic',
            filter_action: 'hide',
            context: %w(home),
            keywords: contain_exactly(
              include(keyword: 'magic', whole_word: true)
            )
          )

        filter = user.account.custom_filters.first

        expect(filter).to be_present
        expect(filter.keywords.pluck(:keyword)).to eq ['magic']
        expect(filter.context).to eq %w(home)
        expect(filter.irreversible?).to be true
        expect(filter.expires_at).to be_nil
      end
    end

    context 'when the required title param is missing' do
      let(:params) { { context: %w(home), filter_action: 'hide', keywords_attributes: [keyword: 'magic'] } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the required context param is missing' do
      let(:params) { { title: 'magic', filter_action: 'hide', keywords_attributes: [keyword: 'magic'] } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the given context value is invalid' do
      let(:params) { { title: 'magic', context: %w(shaolin), filter_action: 'hide', keywords_attributes: [keyword: 'magic'] } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the given filter_action value is invalid' do
      let(:params) { { title: 'magic', filter_action: 'imaginary_value', keywords_attributes: [keyword: 'magic'] } }

      it 'returns http unprocessable entity' do
        subject

        expect(response)
          .to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to include(error: /Action is not included/)
      end
    end
  end

  describe 'GET /api/v2/filters/:id' do
    subject do
      get "/api/v2/filters/#{filter.id}", headers: headers
    end

    let(:filter) { Fabricate(:custom_filter, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'write write:filters'
    it_behaves_like 'unauthorized for invalid token'

    it 'returns the filter successfully', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to include(
          id: filter.id.to_s
        )
    end

    context 'when the filter belongs to someone else' do
      let(:filter) { Fabricate(:custom_filter) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'PUT /api/v2/filters/:id' do
    subject do
      put "/api/v2/filters/#{filter.id}", params: params, headers: headers
    end

    let!(:filter)  { Fabricate(:custom_filter, account: user.account) }
    let!(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }
    let(:params)   { {} }

    it_behaves_like 'forbidden for wrong scope', 'read read:filters'
    it_behaves_like 'unauthorized for invalid token'

    context 'when updating filter parameters' do
      context 'with valid params' do
        let(:params) { { title: 'updated', context: %w(home public) } }

        it 'updates the filter successfully', :aggregate_failures do
          subject

          filter.reload

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(filter.title).to eq 'updated'
          expect(filter.reload.context).to eq %w(home public)
        end
      end

      context 'with invalid params' do
        let(:params) { { title: 'updated', context: %w(word) } }

        it 'returns http unprocessable entity' do
          subject

          expect(response).to have_http_status(422)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end

    context 'when updating keywords in bulk' do
      let(:params) { { keywords_attributes: [{ id: keyword.id, keyword: 'updated' }] } }

      before do
        allow(redis).to receive_messages(publish: nil)
      end

      it 'returns http success and updates keyword and sends a filters_changed event' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(keyword.reload.keyword).to eq 'updated'

        expect(redis).to have_received(:publish).with("timeline:#{user.account.id}", Oj.dump(event: :filters_changed)).once
      end
    end

    context 'when the filter belongs to someone else' do
      let(:filter) { Fabricate(:custom_filter) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'DELETE /api/v2/filters/:id' do
    subject do
      delete "/api/v2/filters/#{filter.id}", headers: headers
    end

    let(:filter) { Fabricate(:custom_filter, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:filters'
    it_behaves_like 'unauthorized for invalid token'

    it 'returns http success and removes the filter' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect { filter.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    context 'when the filter belongs to someone else' do
      let(:filter) { Fabricate(:custom_filter) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
