# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tags' do
  describe 'GET /tags/:id' do
    context 'when tag exists' do
      let(:tag) { Fabricate :tag }

      context 'with HTML format' do
        before { get tag_path(tag) }

        it 'returns page with links to alternate resources' do
          expect(rss_links.first[:href])
            .to eq(tag_url(tag))
          expect(activity_json_links.first[:href])
            .to eq(tag_url(tag))
        end

        def rss_links
          alternate_links.css('[type="application/rss+xml"]')
        end

        def activity_json_links
          alternate_links.css('[type="application/activity+json"]')
        end

        def alternate_links
          response.parsed_body.css('link[rel=alternate]')
        end
      end

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
