# frozen_string_literal: true

require 'rails_helper'

describe 'Log Out' do
  include RoutingHelper

  describe 'DELETE /auth/sign_out' do
    let(:user) { Fabricate(:user) }

    before do
      sign_in user
    end

    it 'Logs out the user and redirect' do
      delete '/auth/sign_out'

      expect(response).to redirect_to('/auth/sign_in')
    end

    it 'Logs out the user and return a page to redirect to with a JSON request' do
      delete '/auth/sign_out', headers: { 'HTTP_ACCEPT' => 'application/json' }

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'

      expect(body_as_json[:redirect_to]).to eq '/auth/sign_in'
    end
  end
end
