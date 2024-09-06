# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/web/embed' do
  subject { get "/api/web/embeds/#{id}", headers: headers }

  context 'when accessed anonymously' do
    let(:headers) { {} }

    context 'when the requested status is local' do
      let(:id) { status.id }

      context 'when the requested status is public' do
        let(:status) { Fabricate(:status, visibility: :public) }

        it 'returns JSON with an html attribute' do
          subject

          expect(response).to have_http_status(200)
          expect(response.parsed_body[:html]).to be_present
        end
      end

      context 'when the requested status is private' do
        let(:status) { Fabricate(:status, visibility: :private) }

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
        end
      end
    end

    context 'when the requested status is remote' do
      let(:remote_account) { Fabricate(:account, domain: 'example.com') }
      let(:status)         { Fabricate(:status, visibility: :public, account: remote_account, url: 'https://example.com/statuses/1') }
      let(:id)             { status.id }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end

    context 'when the requested status does not exist' do
      let(:id) { -1 }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end

  context 'with an API token' do
    let(:user)    { Fabricate(:user) }
    let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }
    let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

    context 'when the requested status is local' do
      let(:id) { status.id }

      context 'when the requested status is public' do
        let(:status) { Fabricate(:status, visibility: :public) }

        it 'returns JSON with an html attribute' do
          subject

          expect(response).to have_http_status(200)
          expect(response.parsed_body[:html]).to be_present
        end

        context 'when the requesting user is blocked' do
          before do
            status.account.block!(user.account)
          end

          it 'returns http not found' do
            subject

            expect(response).to have_http_status(404)
          end
        end
      end

      context 'when the requested status is private' do
        let(:status) { Fabricate(:status, visibility: :private) }

        before do
          user.account.follow!(status.account)
        end

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
        end
      end
    end

    context 'when the requested status is remote' do
      let(:remote_account) { Fabricate(:account, domain: 'example.com') }
      let(:status)         { Fabricate(:status, visibility: :public, account: remote_account, url: 'https://example.com/statuses/1') }
      let(:id)             { status.id }

      let(:service_instance) { instance_double(FetchOEmbedService) }

      before do
        allow(FetchOEmbedService).to receive(:new) { service_instance }
        allow(service_instance).to receive(:call) { call_result }
      end

      context 'when the requesting user is blocked' do
        before do
          status.account.block!(user.account)
        end

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
        end
      end

      context 'when successfully fetching OEmbed' do
        let(:call_result) { { html: 'ok' } }

        it 'returns JSON with an html attribute' do
          subject

          expect(response).to have_http_status(200)
          expect(response.parsed_body[:html]).to be_present
        end
      end

      context 'when sanitizing the fragment fails' do
        let(:call_result) { { html: 'ok' } }

        before { allow(Sanitize).to receive(:fragment).and_raise(ArgumentError) }

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
        end
      end

      context 'when failing to fetch OEmbed' do
        let(:call_result) { nil }

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
        end
      end
    end

    context 'when the requested status does not exist' do
      let(:id) { -1 }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end
end
