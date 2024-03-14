# frozen_string_literal: true

require 'rails_helper'

describe Api::ErrorHandling do
  before do
    stub_const('FakeService', Class.new)
  end

  controller(Api::BaseController) do
    def failure
      FakeService.new
    end
  end

  describe 'error handling' do
    before do
      routes.draw { get 'failure' => 'api/base#failure' }
    end

    {
      ActiveRecord::RecordInvalid => { code: 422 },
      ActiveRecord::RecordNotFound => { code: 404 },
      ActiveRecord::RecordNotUnique => { code: 422 },
      Date::Error => { code: 422 },
      HTTP::Error => { code: 503 },
      Mastodon::InvalidParameterError => { code: 400 },
      Mastodon::NotPermittedError => { code: 403 },
      Mastodon::RaceConditionError => { code: 503 },
      Mastodon::RateLimitExceededError => { code: 429 },
      Mastodon::UnexpectedResponseError => { code: 503 },
      Mastodon::ValidationError => { code: 422 },
      OpenSSL::SSL::SSLError => { code: 503 },
      Seahorse::Client::NetworkingError => { code: 503 },
      Stoplight::Error::RedLight => { code: 503 },
    }.each do |error, options|
      it "Handles error class of #{error}" do
        allow(FakeService)
          .to receive(:new)
          .and_raise(error)

        get :failure

        expect(response)
          .to have_http_status(options[:code])
        expect(FakeService)
          .to have_received(:new)
      end
    end
  end
end
