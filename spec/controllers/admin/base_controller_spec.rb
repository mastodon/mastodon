# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BaseController do
  render_views

  controller do
    def success
      authorize :dashboard, :index?
      render html: '<p>success</p>', layout: true
    end
  end

  before { routes.draw { get 'success' => 'admin/base#success' } }

  context 'when signed in as regular user' do
    before { sign_in Fabricate(:user) }

    it 'responds with unauthorized' do
      get :success

      expect(response).to have_http_status(403)
    end
  end

  context 'when signed in as moderator' do
    before { sign_in Fabricate(:moderator_user) }

    it 'returns success with private headers and admin layout' do
      get :success

      expect(response)
        .to have_http_status(200)
      expect(response.headers['Cache-Control'])
        .to include('private, no-store')
      expect(response.parsed_body)
        .to have_css('body.admin')
    end
  end

  context 'when signed in as admin' do
    before { sign_in Fabricate(:admin_user) }

    it 'returns success with private headers and admin layout' do
      get :success

      expect(response)
        .to have_http_status(200)
      expect(response.headers['Cache-Control'])
        .to include('private, no-store')
      expect(response.parsed_body)
        .to have_css('body.admin')
    end
  end
end
