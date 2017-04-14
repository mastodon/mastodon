require 'rails_helper'

RSpec.describe Api::V1::InstancesController, type: :controller do
  render_views

  describe 'GET #show' do
    it 'returns the correct keys' do
      get :show
      json = body_as_json
      expect(json.keys).to match_array %w(
        description
        email
        title
        uri
        version
      ).map(&:to_sym)
    end
  end
end
