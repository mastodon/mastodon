# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BaseController do
  controller do
    def success
      authorize :dashboard, :index?
      render 'admin/reports/show'
    end
  end

  before { routes.draw { get 'success' => 'admin/base#success' } }

  context 'when accessed by regular user' do
    before { sign_in(Fabricate(:user)) }

    it 'returns forbidden' do
      get :success

      expect(response)
        .to have_http_status(403)
    end
  end

  context 'when accessed by moderator' do
    before { sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Moderator'))) }

    it 'returns http success, private cache control, and uses admin layout' do
      get :success

      expect(response)
        .to have_http_status(200)
      expect(response.headers['Cache-Control'])
        .to include('private, no-store')
      expect(response)
        .to render_template layout: 'admin'
    end
  end

  context 'when accessed by admin' do
    before { sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Admin'))) }

    it 'returns http success and uses admin layout' do
      get :success

      expect(response)
        .to have_http_status(200)
      expect(response)
        .to render_template layout: 'admin'
    end
  end
end
