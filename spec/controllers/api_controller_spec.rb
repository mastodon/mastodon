# frozen_string_literal: true

require 'rails_helper'

describe ApiController, type: :controller do
  controller do
    def success
      head 200
    end
  end

  it 'does not protect from forgery' do
    ActionController::Base.allow_forgery_protection = true
    routes.draw { post 'success' => 'api#success' }
    post 'success'
    expect(response).to have_http_status(:success)
  end
end
