# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Markers' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:statuses write:statuses' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/markers' do
    before do
      Fabricate(:marker, timeline: 'home', last_read_id: 123, user: user)
      Fabricate(:marker, timeline: 'notifications', last_read_id: 456, user: user)

      get '/api/v1/markers', headers: headers, params: { timeline: %w(home notifications) }
    end

    it 'returns markers', :aggregate_failures do
      expect(response).to have_http_status(200)
      expect(response.parsed_body)
        .to include(
          home: include(last_read_id: '123'),
          notifications: include(last_read_id: '456')
        )
    end
  end

  describe 'POST /api/v1/markers' do
    context 'when no marker exists' do
      before do
        post '/api/v1/markers', headers: headers, params: { home: { last_read_id: '69420' } }
      end

      it 'creates a marker', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(user.markers.first.timeline).to eq 'home'
        expect(user.markers.first.last_read_id).to eq 69_420
      end
    end

    context 'when a marker exists' do
      before do
        post '/api/v1/markers', headers: headers, params: { home: { last_read_id: '69420' } }
        post '/api/v1/markers', headers: headers, params: { home: { last_read_id: '70120' } }
      end

      it 'updates a marker', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(user.markers.first.timeline).to eq 'home'
        expect(user.markers.first.last_read_id).to eq 70_120
      end
    end

    context 'when database object becomes stale' do
      before do
        allow(Marker).to receive(:transaction).and_raise(ActiveRecord::StaleObjectError)
        post '/api/v1/markers', headers: headers, params: { home: { last_read_id: '69420' } }
      end

      it 'returns error json' do
        expect(response)
          .to have_http_status(409)
        expect(response.parsed_body)
          .to include(error: /Conflict during update/)
      end
    end
  end
end
