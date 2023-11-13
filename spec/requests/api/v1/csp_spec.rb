# frozen_string_literal: true

require 'rails_helper'

describe 'API namespace minimal Content-Security-Policy' do
  before do
    # Replaces an already-routed-to API controller
    stub_const('Api::V1::SuggestionsController', test_controller)
  end

  it 'returns the correct CSP headers' do
    get '/api/v1/suggestions'

    expect(response).to have_http_status(200)
    expect(response.headers['Content-Security-Policy']).to eq(minimal_csp_headers)
  end

  private

  def test_controller
    Class.new(Api::BaseController) do
      def index
        head 200
      end
    end
  end

  def minimal_csp_headers
    "default-src 'none'; frame-ancestors 'none'; form-action 'none'"
  end
end
