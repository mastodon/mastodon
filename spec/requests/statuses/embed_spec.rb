# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Status embed' do
  describe 'GET /users/:account_username/statuses/:id/embed' do
    subject { get "/users/#{account.username}/statuses/#{status.id}/embed" }

    let(:account) { Fabricate(:account) }
    let(:status)  { Fabricate(:status, account: account) }

    context 'when account is suspended' do
      let(:account) { Fabricate(:account, suspended: true) }

      it 'returns http gone' do
        subject

        expect(response)
          .to have_http_status(410)
      end
    end

    context 'when status is a reblog' do
      let(:original_account) { Fabricate(:account, domain: 'example.com') }
      let(:original_status) { Fabricate(:status, account: original_account, url: 'https://example.com/123') }
      let(:status) { Fabricate(:status, account: account, reblog: original_status) }

      it 'returns http not found' do
        subject

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'when status is public' do
      it 'renders status successfully', :aggregate_failures do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.parsed_body.at('body.embed'))
          .to be_present
        expect(response.headers).to include(
          'Vary' => 'Accept, Accept-Language, Cookie',
          'Cache-Control' => include('public'),
          'Link' => include('activity+json')
        )
      end
    end

    context 'when status is private' do
      let(:status) { Fabricate(:status, account: account, visibility: :private) }

      it 'returns http not found' do
        subject

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'when status is direct' do
      let(:status) { Fabricate(:status, account: account, visibility: :direct) }

      it 'returns http not found' do
        subject

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
