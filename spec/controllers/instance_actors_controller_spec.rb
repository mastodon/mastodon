require 'rails_helper'

RSpec.describe InstanceActorsController, type: :controller do
  describe 'GET #show' do
    context 'as JSON' do
      let(:format) { 'json' }

      shared_examples 'shared behavior' do
        before do
          get :show, params: { format: format }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it 'does not set cookies' do
          expect(response.cookies).to be_empty
          expect(response.headers['Set-Cookies']).to be_nil
        end

        it 'does not set sessions' do
          expect(session).to be_empty
        end

        it 'returns public Cache-Control header' do
          expect(response.headers['Cache-Control']).to include 'public'
        end

        it 'renders account' do
          json = body_as_json
          expect(json).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :inbox, :outbox, :url)
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
