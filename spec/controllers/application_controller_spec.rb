# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  render_views

  controller do
    def success = head(200)
  end

  context 'with a forgery' do
    before do
      ActionController::Base.allow_forgery_protection = true
      routes.draw { post 'success' => 'anonymous#success' }
    end

    it 'responds with 422 and error page' do
      post 'success'

      expect(response)
        .to have_http_status(422)
    end
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

  describe 'helper_method :current_flavour' do
    it 'returns "glitch" when theme wasn\'t changed in admin settings' do
      allow(Setting).to receive(:default_settings).and_return({ 'skin' => 'default' })
      allow(Setting).to receive(:default_settings).and_return({ 'flavour' => 'glitch' })

      expect(controller.view_context.current_flavour).to eq 'glitch'
    end

    it 'returns instances\'s flavour when user is not signed in' do
      allow(Setting).to receive(:[]).with('skin').and_return 'default'
      allow(Setting).to receive(:[]).with('flavour').and_return 'vanilla'

      expect(controller.view_context.current_flavour).to eq 'vanilla'
    end

    it 'returns instances\'s default flavour when user didn\'t set theme' do
      current_user = Fabricate(:user)
      sign_in current_user

      allow(Setting).to receive(:[]).with('skin').and_return 'default'
      allow(Setting).to receive(:[]).with('flavour').and_return 'vanilla'
      allow(Setting).to receive(:[]).with('noindex').and_return false

      expect(controller.view_context.current_flavour).to eq 'vanilla'
    end

    it 'returns user\'s flavour when it is set' do
      current_user = Fabricate(:user)
      current_user.settings.update(flavour: 'glitch')
      current_user.save
      sign_in current_user

      allow(Setting).to receive(:[]).with('skin').and_return 'default'
      allow(Setting).to receive(:[]).with('flavour').and_return 'vanilla'

      expect(controller.view_context.current_flavour).to eq 'glitch'
    end
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
end
