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
      ActiveRecord::RecordInvalid => { code: 422, error: /invalid/ },
      ActiveRecord::RecordNotFound => { code: 404, error: I18n.t('api.errors.record_not_found') },
      ActiveRecord::RecordNotUnique => { code: 422, error: I18n.t('api.errors.record_not_unique') },
      Date::Error => { code: 422, error: I18n.t('api.errors.invalid_date') },
      HTTP::Error => { code: 503, error: I18n.t('api.errors.remote_data_fetch') },
      Mastodon::InvalidParameterError => { code: 400, error: /Invalid/ },
      Mastodon::NotPermittedError => { code: 403, error: I18n.t('api.errors.not_permitted') },
      Mastodon::RaceConditionError => { code: 503, error: I18n.t('api.errors.temporary_problem') },
      Mastodon::RateLimitExceededError => { code: 429, error: I18n.t('errors.429') },
      Mastodon::UnexpectedResponseError => { code: 503, error: I18n.t('api.errors.remote_data_fetch') },
      Mastodon::ValidationError => { code: 422, error: /Validation/ },
      OpenSSL::SSL::SSLError => { code: 503, error: I18n.t('api.errors.ssl_error') },
      Seahorse::Client::NetworkingError => { code: 503, error: I18n.t('api.errors.temporary_problem') },
      Stoplight::Error::RedLight => { code: 503, error: I18n.t('api.errors.temporary_problem') },
    }.each do |error_class, options|
      it "Handles error class of #{error_class}" do
        allow(FakeService).to receive(:new).and_raise(error_class)

        get :failure

        expect(response)
          .to have_http_status(options[:code])

        expect(body_as_json)
          .to include(
            error: match(options[:error])
          )

        expect(FakeService)
          .to have_received(:new)
      end
    end
  end
end
