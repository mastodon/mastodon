# frozen_string_literal: true

require 'rails_helper'

describe Api::BaseController do
  controller do
    def success
      head 200
    end
  end

  before do
    routes.draw { post 'success' => 'api/base#success' }
  end

  it 'does not protect from forgery' do
    ActionController::Base.allow_forgery_protection = true
    post 'success'
    expect(response).to have_http_status(:success)
  end
end
