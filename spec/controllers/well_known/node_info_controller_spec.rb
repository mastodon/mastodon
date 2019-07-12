require 'rails_helper'

describe WellKnown::NodeInfoController, type: :controller do
  render_views

  describe 'GET #index' do
    it 'returns json document pointing to node info' do
      get :index

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(response.content_type).to eq 'application/json'
      expect(json_response.keys.include?('links')).to be true
      expect(json_response['links'][0]['rel']).to eq 'http://nodeinfo.diaspora.software/ns/schema/2.0'
      expect(json_response['links'][0]['href'].include?('nodeinfo/2.0')).to be true
      expect(json_response['links'][0]['rel']).to eq 'http://nodeinfo.diaspora.software/ns/schema/2.1'
      expect(json_response['links'][0]['href'].include?('nodeinfo/2.1')).to be true
    end
  end

  describe 'GET #show' do
    it 'returns json document pointing to node info' do
      get :show, params: { version_number: 2 }

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(response.content_type).to eq 'application/json'
      expect(json_response.keys.include?('version')).to be true
      expect(json_response.keys.include?('usage')).to be true
      expect(json_response.keys.include?('software')).to be true
      expect(json_response.keys.include?('services')).to be true
      expect(json_response.keys.include?('protocols')).to be true
      expect(json_response.keys.include?('openRegistrations')).to be true
      expect(json_response.keys.include?('usage')).to be true
      expect(json_response.keys.include?('metaData')).to be true
    end
  end
end
