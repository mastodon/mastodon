# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::VerificationsController do
  render_views

  let!(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    before do
      get :show
    end

    it 'returns http success with private cache control headers', :aggregate_failures do
      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          headers: include(
            'Cache-Control' => 'private, no-store'
          )
        )
    end
  end
end
