# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorResponses do
  render_views

  shared_examples 'error response' do |code|
    before { routes.draw { get 'show' => 'anonymous#show' } }

    it "returns http #{code} and renders error template" do
      get 'show'

      expect(response)
        .to have_http_status(code)
      expect(response.parsed_body)
        .to have_css('body[class=error]')
        .and have_css('h1', text: error_content(code))
    end

    def error_content(code)
      I18n.t("errors.#{code}")
        .then { |value| I18n.t("errors.#{code}.content") if value.is_a?(Hash) }
    end
  end

  describe 'bad_request' do
    controller(ApplicationController) do
      def show = bad_request
    end

    it_behaves_like 'error response', 400
  end

  describe 'forbidden' do
    controller(ApplicationController) do
      def show = forbidden
    end

    it_behaves_like 'error response', 403
  end

  describe 'gone' do
    controller(ApplicationController) do
      def show = gone
    end

    it_behaves_like 'error response', 410
  end

  describe 'internal_server_error' do
    controller(ApplicationController) do
      def show = internal_server_error
    end

    it_behaves_like 'error response', 500
  end

  describe 'not_acceptable' do
    controller(ApplicationController) do
      def show = not_acceptable
    end

    it_behaves_like 'error response', 406
  end

  describe 'not_found' do
    controller(ApplicationController) do
      def show = not_found
    end

    it_behaves_like 'error response', 404
  end

  describe 'service_unavailable' do
    controller(ApplicationController) do
      def show = service_unavailable
    end

    it_behaves_like 'error response', 503
  end

  describe 'too_many_requests' do
    controller(ApplicationController) do
      def show = too_many_requests
    end

    it_behaves_like 'error response', 429
  end

  describe 'unprocessable_content' do
    controller(ApplicationController) do
      def show = unprocessable_content
    end

    it_behaves_like 'error response', 422
  end

  context 'with ActionController::RoutingError' do
    controller(ApplicationController) do
      def show
        raise ActionController::RoutingError, ''
      end
    end

    it_behaves_like 'error response', 404
  end

  context 'with ActiveRecord::RecordNotFound' do
    controller(ApplicationController) do
      def show
        raise ActiveRecord::RecordNotFound, ''
      end
    end

    it_behaves_like 'error response', 404
  end

  context 'with ActionController::InvalidAuthenticityToken' do
    controller(ApplicationController) do
      def show
        raise ActionController::InvalidAuthenticityToken, ''
      end
    end

    it_behaves_like 'error response', 422
  end
end
