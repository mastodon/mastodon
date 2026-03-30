# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ErrorHandling do
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
      ActiveRecord::RecordInvalid => 422,
      ActiveRecord::RecordNotFound => 404,
      ActiveRecord::RecordNotUnique => 422,
      Date::Error => 422,
      HTTP::Error => 503,
      Mastodon::InvalidParameterError => 400,
      Mastodon::NotPermittedError => 403,
      Mastodon::RaceConditionError => 503,
      Mastodon::RateLimitExceededError => 429,
      Mastodon::UnexpectedResponseError => 503,
      Mastodon::ValidationError => 422,
      OpenSSL::SSL::SSLError => 503,
      Seahorse::Client::NetworkingError => 503,
      Stoplight::Error::RedLight.new(:name, cool_off_time: 1, retry_after: 1) => 503,
    }.each do |error, code|
      it "Handles error class of #{error}" do
        allow(FakeService)
          .to receive(:new)
          .and_raise(error)

        get :failure

        expect(response)
          .to have_http_status(code)
        expect(FakeService)
          .to have_received(:new)
      end
    end
  end
end
