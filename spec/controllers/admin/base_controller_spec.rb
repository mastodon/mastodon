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

  it 'requires administrator or moderator' do
    sign_in(Fabricate(:user))
    get :success

    expect(response).to have_http_status(403)
  end

  it 'returns private cache control headers' do
    sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Moderator')))
    get :success

    expect(response.headers['Cache-Control']).to include('private, no-store')
  end

  it 'renders admin layout as a moderator' do
    sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Moderator')))
    get :success
    expect(response).to render_template layout: 'admin'
  end

  it 'renders admin layout as an admin' do
    sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Admin')))
    get :success
    expect(response).to render_template layout: 'admin'
  end
end
