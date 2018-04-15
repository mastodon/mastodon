# frozen_string_literal: true

require 'rails_helper'

describe Admin::BaseController, type: :controller do
  controller do
    def success
      render 'admin/reports/show'
    end
  end

  it 'requires administrator or moderator' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, admin: false, moderator: false))
    get :success

    expect(response).to have_http_status(:forbidden)
  end

  it 'renders admin layout as a moderator' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, moderator: true))
    get :success
    expect(response).to render_template layout: 'admin'
  end

  it 'renders admin layout as an admin' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, admin: true))
    get :success
    expect(response).to render_template layout: 'admin'
  end
end
