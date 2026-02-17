# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Donation campaigns' do
  include_context 'with API authentication'

  describe 'GET /api/v1/donation_campaigns' do
    context 'when not authenticated' do
      it 'returns http unprocessable entity' do
        get '/api/v1/donation_campaigns'

        expect(response)
          .to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when no donation campaign API is set up' do
      it 'returns http empty' do
        get '/api/v1/donation_campaigns', headers: headers

        expect(response)
          .to have_http_status(204)
      end
    end

    context 'when a donation campaign API is set up' do
      let(:api_url) { 'https://example.org/donations' }
      let(:seed) { Random.new(user.account_id).rand(100) }

      around do |example|
        original = Rails.configuration.x.donation_campaigns.api_url
        Rails.configuration.x.donation_campaigns.api_url = api_url

        example.run

        Rails.configuration.x.donation_campaigns.api_url = original
      end

      context 'when the donation campaign API does not return a campaign' do
        before do
          stub_request(:get, "#{api_url}?platform=web&seed=#{seed}&locale=en").to_return(status: 204)
        end

        it 'returns http empty' do
          get '/api/v1/donation_campaigns', headers: headers

          expect(response)
            .to have_http_status(204)
        end
      end

      context 'when the donation campaign API returns a campaign' do
        let(:campaign_json) do
          {
            'id' => 'campaign-1',
            'banner_message' => 'Hi',
            'banner_button_text' => 'Donate!',
            'donation_message' => 'Hi!',
            'donation_button_text' => 'Money',
            'donation_success_post' => 'Success post',
            'amounts' => {
              'one_time' => {
                'EUR' => [1, 2, 3],
                'USD' => [4, 5, 6],
              },
              'monthly' => {
                'EUR' => [1],
                'USD' => [2],
              },
            },
            'default_currency' => 'EUR',
            'donation_url' => 'https://sponsor.joinmastodon.org/donate/new',
            'locale' => 'en',
          }
        end

        before do
          stub_request(:get, "#{api_url}?platform=web&seed=#{seed}&locale=en").to_return(body: Oj.dump(campaign_json), status: 200)
        end

        it 'returns the expected campaign' do
          get '/api/v1/donation_campaigns', headers: headers

          expect(response)
            .to have_http_status(200)

          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to match(campaign_json)

          expect(Rails.cache.read("donation_campaign_request:#{seed}:en", raw: true))
            .to eq 'campaign-1:en'

          expect(Oj.load(Rails.cache.read('donation_campaign:campaign-1:en', raw: true)))
            .to match(campaign_json)
        end
      end
    end
  end
end
