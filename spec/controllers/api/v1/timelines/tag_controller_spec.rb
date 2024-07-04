# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Timelines::TagController do
  render_views

  let(:user)   { Fabricate(:user) }
  let(:scopes) { 'read:statuses' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    subject do
      get :show, params: { id: 'test' }
    end

    before do
      PostStatusService.new.call(user.account, text: 'It is a #test')
    end

    context 'when the instance allows public preview' do
      context 'when the user is not authenticated' do
        let(:token) { nil }

        it 'returns http success', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.headers['Link'].links.size).to eq(2)
        end
      end

      context 'when the user is authenticated' do
        it 'returns http success', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.headers['Link'].links.size).to eq(2)
        end
      end
    end

    context 'when the instance does not allow public preview' do
      before do
        Form::AdminSettings.new(timeline_preview: false).save
      end

      context 'without an access token' do
        let(:token) { nil }

        it 'returns http unprocessable entity' do
          subject

          expect(response).to have_http_status(422)
        end
      end

      context 'with an application access token, not bound to a user' do
        let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil, scopes: scopes) }

        it 'returns http unprocessable entity' do
          subject

          expect(response).to have_http_status(422)
        end
      end

      context 'when the user is authenticated' do
        it 'returns http success', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.headers['Link'].links.size).to eq(2)
        end
      end
    end
  end
end
