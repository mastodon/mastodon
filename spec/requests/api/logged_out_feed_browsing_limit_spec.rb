# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Logged-out feed browsing limit' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:statuses') }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:tag)     { Fabricate(:tag, name: 'test') }
  let(:url)     { 'https://example.com/' }

  before do
    Setting.trends = true

    preview_card = Fabricate(:preview_card, url: url)
    preview_card.create_trend!(allowed: true)

    Fabricate.times(3, :status, account: Fabricate.build(:account, domain: nil, discoverable: true), trendable: true, language: 'en').each do |status|
      status.tags << tag
      PreviewCardsStatus.create(status: status, preview_card: preview_card, url: url)
      status.increment_count!(:reblogs_count)
    end
    Trends.statuses.refresh

    Setting.limit_logged_out_feed_browsing = limited
  end

  shared_examples 'a feed with a logged-out browsing limit' do |path, first_page_params, next_page_params|
    context 'when the limit is enabled' do
      let(:limited) { true }

      it 'serves the first page to logged-out visitors without pagination links', :aggregate_failures do
        get public_send(path), params: first_page_params

        expect(response).to have_http_status(200)
        expect(response.headers['Link']).to be_nil
      end

      it 'requires an authenticated user to page through the feed' do
        get public_send(path), params: first_page_params.merge(next_page_params)

        expect(response).to have_http_status(422)
      end

      it 'lets authenticated users page through the feed' do
        get public_send(path), params: first_page_params.merge(next_page_params), headers: headers

        expect(response).to have_http_status(200)
      end
    end

    context 'when the limit is disabled' do
      let(:limited) { false }

      it 'lets logged-out visitors page through the feed' do
        get public_send(path), params: first_page_params.merge(next_page_params)

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /api/v1/timelines/public' do
    let(:public_path) { '/api/v1/timelines/public' }

    it_behaves_like 'a feed with a logged-out browsing limit', :public_path, { local: true }, { max_id: '1000000000000000000' }
    it_behaves_like 'a feed with a logged-out browsing limit', :public_path, { local: true }, { min_id: '1' }
  end

  describe 'GET /api/v1/timelines/tag/:hashtag' do
    let(:tag_path) { '/api/v1/timelines/tag/test' }

    it_behaves_like 'a feed with a logged-out browsing limit', :tag_path, {}, { max_id: '1000000000000000000' }
  end

  describe 'GET /api/v1/timelines/link' do
    let(:link_path) { '/api/v1/timelines/link' }

    it_behaves_like 'a feed with a logged-out browsing limit', :link_path, { url: 'https://example.com/' }, { max_id: '1000000000000000000' }
  end

  describe 'GET /api/v1/trends/statuses' do
    let(:trends_path) { '/api/v1/trends/statuses' }

    it_behaves_like 'a feed with a logged-out browsing limit', :trends_path, {}, { offset: '1' }
  end
end
