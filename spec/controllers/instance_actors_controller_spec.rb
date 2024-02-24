# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstanceActorsController do
  describe 'GET #show' do
    context 'with JSON' do
      let(:format) { 'json' }

      shared_examples 'shared behavior' do
        before do
          get :show, params: { format: format }
        end

        it 'returns http success with correct media type, headers, and session values' do
          expect(response)
            .to have_http_status(200)
            .and have_attributes(
              media_type: eq('application/activity+json'),
              cookies: be_empty
            )

          expect(response.headers)
            .to include('Cache-Control' => include('public'))
            .and not_include('Set-Cookies')

          expect(session).to be_empty

          expect(body_as_json)
            .to include(:id, :type, :preferredUsername, :inbox, :publicKey, :inbox, :outbox, :url)
        end
      end

      before do
        allow(controller).to receive(:authorized_fetch_mode?).and_return(authorized_fetch_mode)
      end

      context 'without authorized fetch mode' do
        let(:authorized_fetch_mode) { false }

        it_behaves_like 'shared behavior'
      end

      context 'with authorized fetch mode' do
        let(:authorized_fetch_mode) { true }

        it_behaves_like 'shared behavior'
      end
    end
  end
end
