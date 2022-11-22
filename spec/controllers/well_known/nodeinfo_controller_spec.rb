require 'rails_helper'

RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    schema_directory = "#{Dir.pwd}/spec/support/"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, response.body, strict: true)
  end
end

describe WellKnown::NodeInfoController, type: :controller do
  render_views

  describe 'GET #index' do
    it 'returns json document pointing to node info' do
      get :index

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'

      json = body_as_json

      expect(json[:links]).to be_an Array
      expect(json[:links][0][:rel]).to eq 'http://nodeinfo.diaspora.software/ns/schema/2.0'
      expect(json[:links][0][:href]).to include 'nodeinfo/2.0'
    end
  end

  describe 'GET #show' do
    it 'returns json document with node info properties' do
      get :show

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'

      json = body_as_json
      
      expect(json).to match_response_schema("node_info_2.0_schema")
      expect(json[:version]).to eq '2.0'
      expect(json[:usage]).to be_a Hash
      expect(json[:software]).to be_a Hash
      expect(json[:protocols]).to be_an Array
    end
  end
end
