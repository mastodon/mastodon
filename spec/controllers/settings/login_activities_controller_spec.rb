# frozen_string_literal: true

require 'rails_helper'

describe Settings::LoginActivitiesController do
  render_views

  let!(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'returns http success with private cache control headers', :aggregate_failures do
      get :index

      expect(response)
        .to have_http_status(200)
        .and render_template(:index)
        .and have_attributes(
          headers: hash_including(
            'Cache-Control' => include('private, no-store')
          )
        )
    end
  end
end
