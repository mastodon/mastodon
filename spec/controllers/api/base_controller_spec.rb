# frozen_string_literal: true

require 'rails_helper'

class FakeService; end

describe Api::BaseController do
  controller do
    def success
      head 200
    end

    def error
      FakeService.new
    end
  end

  describe 'Forgery protection' do
    before do
      routes.draw { post 'success' => 'api/base#success' }
    end

    it 'does not protect from forgery' do
      ActionController::Base.allow_forgery_protection = true
      post 'success'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Error handling' do
    ERRORS_WITH_CODES = {
      ActiveRecord::RecordInvalid => 422,
      Mastodon::ValidationError => 422,
      ActiveRecord::RecordNotFound => 404,
      Goldfinger::Error => 422,
      HTTP::Error => 503,
      OpenSSL::SSL::SSLError => 503,
      Mastodon::NotPermittedError => 403,
    }

    before do
      routes.draw { get 'error' => 'api/base#error' }
    end

    ERRORS_WITH_CODES.each do |error, code|
      it "Handles error class of #{error}" do
        expect(FakeService).to receive(:new).and_raise(error)

        get 'error'
        expect(response).to have_http_status(code)
      end
    end
  end
end
