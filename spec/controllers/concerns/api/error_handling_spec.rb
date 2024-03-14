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
      ActiveRecord::RecordInvalid => { code: 422, message: // },
      ActiveRecord::RecordNotFound => { code: 404, message: // },
      ActiveRecord::RecordNotUnique => { code: 422, message: // },
      Date::Error => { code: 422, message: // },
      HTTP::Error => { code: 503, message: // },
      Mastodon::InvalidParameterError => { code: 400, message: // },
      Mastodon::NotPermittedError => { code: 403, message: // },
      Mastodon::RaceConditionError => { code: 503, message: // },
      Mastodon::RateLimitExceededError => { code: 429, message: // },
      Mastodon::UnexpectedResponseError => { code: 503, message: // },
      Mastodon::ValidationError => { code: 422, message: // },
      OpenSSL::SSL::SSLError => { code: 503, message: // },
      Seahorse::Client::NetworkingError => { code: 503, message: // },
      Stoplight::Error::RedLight => { code: 503, message: // },
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
        expect(body_as_json)
          .to include(
            error: match(options[:message])
          )
      end
    end
  end
end
