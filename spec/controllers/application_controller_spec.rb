# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def success
      head 200
    end

    def routing_error
      raise ActionController::RoutingError, ''
    end

    def record_not_found
      raise ActiveRecord::RecordNotFound, ''
    end

    def invalid_authenticity_token
      raise ActionController::InvalidAuthenticityToken, ''
    end
  end

  shared_examples 'respond_with_error' do |code|
    it "returns http #{code} for http and renders template" do
      expect(subject).to render_template("errors/#{code}", layout: 'error')

      expect(response).to have_http_status(code)
    end
  end

  context 'with a forgery' do
    subject do
      ActionController::Base.allow_forgery_protection = true
      routes.draw { post 'success' => 'anonymous#success' }
      post 'success'
    end

    include_examples 'respond_with_error', 422
  end

  describe 'helper_method :current_account' do
    it 'returns nil if not signed in' do
      expect(controller.view_context.current_account).to be_nil
    end

    it 'returns account if signed in' do
      account = Fabricate(:account)
      sign_in(account.user)
      expect(controller.view_context.current_account).to eq account
    end
  end

  describe 'helper_method :single_user_mode?' do
    it 'returns false if it is in single_user_mode but there is no account' do
      allow(Rails.configuration.x).to receive(:single_user_mode).and_return(true)
      expect(controller.view_context.single_user_mode?).to be false
    end

    it 'returns false if there is an account but it is not in single_user_mode' do
      allow(Rails.configuration.x).to receive(:single_user_mode).and_return(false)
      Fabricate(:account)
      expect(controller.view_context.single_user_mode?).to be false
    end

    it 'returns true if it is in single_user_mode and there is an account' do
      allow(Rails.configuration.x).to receive(:single_user_mode).and_return(true)
      Fabricate(:account)
      expect(controller.view_context.single_user_mode?).to be true
    end
  end

  describe 'helper_method :current_theme' do
    it 'returns "default" when theme wasn\'t changed in admin settings' do
      allow(Setting).to receive(:default_settings).and_return({ 'theme' => 'default' })

      expect(controller.view_context.current_theme).to eq 'default'
    end

    it 'returns instances\'s theme when user is not signed in' do
      allow(Setting).to receive(:[]).with('theme').and_return 'contrast'

      expect(controller.view_context.current_theme).to eq 'contrast'
    end

    it 'returns instances\'s default theme when user didn\'t set theme' do
      current_user = Fabricate(:user)
      current_user.settings.update(theme: 'contrast', noindex: false)
      current_user.save
      sign_in current_user

      expect(controller.view_context.current_theme).to eq 'contrast'
    end

    it 'returns user\'s theme when it is set' do
      current_user = Fabricate(:user)
      current_user.settings.update(theme: 'mastodon-light')
      current_user.save
      sign_in current_user

      expect(controller.view_context.current_theme).to eq 'mastodon-light'
    end
  end

  context 'with ActionController::RoutingError' do
    subject do
      routes.draw { get 'routing_error' => 'anonymous#routing_error' }
      get 'routing_error'
    end

    include_examples 'respond_with_error', 404
  end

  context 'with ActiveRecord::RecordNotFound' do
    subject do
      routes.draw { get 'record_not_found' => 'anonymous#record_not_found' }
      get 'record_not_found'
    end

    include_examples 'respond_with_error', 404
  end

  context 'with ActionController::InvalidAuthenticityToken' do
    subject do
      routes.draw { get 'invalid_authenticity_token' => 'anonymous#invalid_authenticity_token' }
      get 'invalid_authenticity_token'
    end

    include_examples 'respond_with_error', 422
  end

  describe 'before_action :check_suspension' do
    before do
      routes.draw { get 'success' => 'anonymous#success' }
    end

    it 'does nothing if not signed in' do
      get 'success'
      expect(response).to have_http_status(200)
    end

    it 'does nothing if user who signed in is not suspended' do
      sign_in(Fabricate(:account, suspended: false).user)
      get 'success'
      expect(response).to have_http_status(200)
    end

    it 'redirects to account status page' do
      sign_in(Fabricate(:account, suspended: true).user)
      get 'success'
      expect(response).to redirect_to(edit_user_registration_path)
    end
  end

  describe 'raise_not_found' do
    it 'raises error' do
      controller.params[:unmatched_route] = 'unmatched'
      expect { controller.raise_not_found }.to raise_error(ActionController::RoutingError, 'No route matches unmatched')
    end
  end

  describe 'forbidden' do
    controller do
      def route_forbidden
        forbidden
      end
    end

    subject do
      routes.draw { get 'route_forbidden' => 'anonymous#route_forbidden' }
      get 'route_forbidden'
    end

    include_examples 'respond_with_error', 403
  end

  describe 'not_found' do
    controller do
      def route_not_found
        not_found
      end
    end

    subject do
      routes.draw { get 'route_not_found' => 'anonymous#route_not_found' }
      get 'route_not_found'
    end

    include_examples 'respond_with_error', 404
  end

  describe 'gone' do
    controller do
      def route_gone
        gone
      end
    end

    subject do
      routes.draw { get 'route_gone' => 'anonymous#route_gone' }
      get 'route_gone'
    end

    include_examples 'respond_with_error', 410
  end

  describe 'unprocessable_entity' do
    controller do
      def route_unprocessable_entity
        unprocessable_entity
      end
    end

    subject do
      routes.draw { get 'route_unprocessable_entity' => 'anonymous#route_unprocessable_entity' }
      get 'route_unprocessable_entity'
    end

    include_examples 'respond_with_error', 422
  end
end
