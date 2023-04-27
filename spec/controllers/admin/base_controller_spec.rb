# frozen_string_literal: true

require 'rails_helper'

describe Admin::BaseController, type: :controller do
  controller do
    def success
      authorize :dashboard, :index?
      render 'admin/reports/show'
    end
  end

  it 'requires administrator or moderator' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user))
    get :success

    expect(response).to have_http_status(403)
  end

  it 'returns private cache control headers' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Moderator')))
    get :success

    expect(response.headers['Cache-Control']).to include('private, no-store')
  end

  it 'renders admin layout as a moderator' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Moderator')))
    get :success
    expect(response).to render_template layout: 'admin'
  end

  it 'renders admin layout as an admin' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Admin')))
    get :success
    expect(response).to render_template layout: 'admin'
  end
end
