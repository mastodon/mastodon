# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tags' do
  describe 'GET /tags/:id' do
    context 'when tag exists' do
      let(:tag) { Fabricate :tag }

      context 'with JSON format' do
        before { get tag_path(tag, format: :json) }

        it 'returns http success' do
          expect(response)
            .to have_http_status(200)
            .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')
          expect(response.content_type)
            .to start_with('application/activity+json')
        end
      end

      context 'with RSS format' do
        before { get tag_path(tag, format: :rss) }

        it 'returns http success' do
          expect(response)
            .to have_http_status(200)
            .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')
          expect(response.content_type)
            .to start_with('application/rss+xml')
        end
      end
    end

    context 'when tag does not exist' do
      before { get tag_path('missing') }

      it 'returns http not found' do
        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
