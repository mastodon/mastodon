# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Markers' do
  include_context 'with API authentication', oauth_scopes: 'read:statuses write:statuses'

  describe 'GET /api/v1/markers' do
    before do
      travel_to DateTime.parse('2026-03-15T12:34:56.789Z'), with_usec: true do
        Fabricate(:marker, timeline: 'home', last_read_id: 123, user: user)
        Fabricate(:marker, timeline: 'notifications', last_read_id: 456, user: user)
      end

      get '/api/v1/markers', headers: headers, params: { timeline: %w(home notifications) }
    end

    it 'returns markers', :aggregate_failures do
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to include(
          home: include(last_read_id: '123'),
          notifications: include(last_read_id: '456')
        )
    end

    it 'uses a specific style of IS08601 timestamps' do
      expect(response.parsed_body)
        .to include(home: include(updated_at: eq('2026-03-15T12:34:56.789Z')))
    end
  end

  describe 'POST /api/v1/markers' do
    context 'when no marker exists' do
      subject { post '/api/v1/markers', headers: headers, params: { home: { last_read_id: '69420' } } }

      it 'creates a marker', :aggregate_failures do
        expect { subject }
          .to change { user.markers.count }.by(1)
        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq('application/json')
        expect(user.markers.first)
          .to have_attributes(timeline: 'home', last_read_id: 69_420)
      end
    end

    context 'with multiple timelines' do
      subject { post '/api/v1/markers', headers: headers, params: { home: { last_read_id: '69420' }, notifications: { last_read_id: '89345' } } }

      it 'creates a marker', :aggregate_failures do
        expect { subject }
          .to change { user.markers.count }.by(2)
        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq('application/json')
        expect(user.markers.first)
          .to have_attributes(timeline: 'home', last_read_id: 69_420)
        expect(user.markers.last)
          .to have_attributes(timeline: 'notifications', last_read_id: 89_345)
      end
    end

    context 'when a marker exists' do
      subject { post '/api/v1/markers', headers: headers, params: { home: { last_read_id: '70120' } } }

      before do
        post '/api/v1/markers', headers: headers, params: { home: { last_read_id: '69420' } }
      end

      it 'updates a marker', :aggregate_failures do
        expect { subject }
          .to_not(change { user.markers.count })

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq('application/json')
        expect(user.markers.first)
          .to have_attributes(timeline: 'home', last_read_id: 70_120)
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
        expect(response.media_type)
          .to eq('application/json')
        expect(response.parsed_body)
          .to include(error: /Conflict during update/)
      end
    end
  end
end
