# frozen_string_literal: true

require 'rails_helper'

describe Admin::BaseController, type: :controller do
  controller do
    def success
      render 'admin/reports/show'
    end
  end

  it 'renders admin layout' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, admin: true))
    get :success
    expect(response).to render_template layout: 'admin'
  end

  it 'requires administrator' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, admin: false))
    get :success

    expect(response).to redirect_to('/')
  end
end
