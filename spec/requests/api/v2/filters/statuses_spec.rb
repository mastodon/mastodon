# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V2 Filters Statuses' do
  let(:user)         { Fabricate(:user) }
  let(:token)        { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:filter)       { Fabricate(:custom_filter, account: user.account) }
  let(:other_user)   { Fabricate(:user) }
  let(:other_filter) { Fabricate(:custom_filter, account: other_user.account) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v2/filters/:filter_id/statuses' do
    let(:scopes) { 'read:filters' }
    let!(:status_filter) { Fabricate(:custom_filter_status, custom_filter: filter) }

    it 'returns http success' do
      get "/api/v2/filters/#{filter.id}/statuses", headers: headers
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to contain_exactly(
          include(id: status_filter.id.to_s)
        )
    end

    context "when trying to access another's user filters" do
      it 'returns http not found' do
        get "/api/v2/filters/#{other_filter.id}/statuses", headers: headers
        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST #create' do
    let(:scopes)    { 'write:filters' }
    let(:filter_id) { filter.id }
    let!(:status)   { Fabricate(:status) }

    before do
      post "/api/v2/filters/#{filter_id}/statuses", headers: headers, params: { status_id: status.id }
    end

    it 'creates a filter', :aggregate_failures do
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect(response.parsed_body)
        .to include(
          status_id: status.id.to_s
        )

      filter = user.account.custom_filters.first
      expect(filter).to_not be_nil
      expect(filter.statuses.pluck(:status_id)).to eq [status.id]
    end

    context "when trying to add to another another's user filters" do
      let(:filter_id) { other_filter.id }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'GET /api/v2/filters/statuses/:id' do
    let(:scopes) { 'read:filters' }
    let!(:status_filter) { Fabricate(:custom_filter_status, custom_filter: filter) }

    before do
      get "/api/v2/filters/statuses/#{status_filter.id}", headers: headers
    end

    it 'responds with the filter', :aggregate_failures do
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect(response.parsed_body)
        .to include(
          status_id: status_filter.status.id.to_s
        )
    end

    context "when trying to access another user's filter keyword" do
      let(:status_filter) { Fabricate(:custom_filter_status, custom_filter: other_filter) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /api/v2/filters/statuses/:id' do
    let(:scopes) { 'write:filters' }
    let(:status_filter) { Fabricate(:custom_filter_status, custom_filter: filter) }

    before do
      delete "/api/v2/filters/statuses/#{status_filter.id}", headers: headers
    end

    it 'destroys the filter', :aggregate_failures do
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect { status_filter.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    context "when trying to update another user's filter keyword" do
      let(:status_filter) { Fabricate(:custom_filter_status, custom_filter: other_filter) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
