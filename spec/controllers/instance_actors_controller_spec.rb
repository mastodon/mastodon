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

        it 'returns http success with correct media type and body' do
          expect(response)
            .to have_http_status(200)
            .and have_attributes(
              media_type: eq('application/activity+json')
            )

          expect(body_as_json)
            .to include(:id, :type, :preferredUsername, :inbox, :publicKey, :inbox, :outbox, :url)
        end

        it_behaves_like 'cacheable response'
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

      context 'with a suspended instance actor' do
        let(:authorized_fetch_mode) { false }

        before { Account.representative.update(suspended_at: 10.days.ago) }

        it_behaves_like 'shared behavior'
      end
    end
  end
end
