# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'email confirmation flow when captcha is enabled' do
  let(:user)        { Fabricate(:user, confirmed_at: nil, confirmation_token: 'foobar', created_by_application: client_app) }
  let(:client_app)  { nil }

  before do
    allow(Auth::ConfirmationsController).to receive(:new).and_return(stubbed_controller)
  end

  context 'when the user signed up through an app' do
    let(:client_app) { Fabricate(:application) }

    it 'logs in' do
      visit "/auth/confirmation?confirmation_token=#{user.confirmation_token}&redirect_to_app=true"

      # It presents the user with a captcha form
      expect(page).to have_title(I18n.t('auth.captcha_confirmation.title'))

      # It redirects to app and confirms user
      expect { click_on I18n.t('challenge.confirm') }
        .to change { user.reload.confirmed? }.from(false).to(true)

      expect(page).to have_current_path(/\A#{client_app.confirmation_redirect_uri}/, url: true)

      # Browsers will generally reload the original page upon redirection
      # to external handlers, so test this as well
      visit "/auth/confirmation?confirmation_token=#{user.confirmation_token}&redirect_to_app=true"

      # It presents a page with a link to the app callback
      expect(page)
        .to have_content(I18n.t('auth.confirmations.registration_complete', domain: 'cb6e6126.ngrok.io'))
        .and have_link(I18n.t('auth.confirmations.clicking_this_link'), href: client_app.confirmation_redirect_uri)
    end
  end

  private

  def stubbed_controller
    Auth::ConfirmationsController.new.tap do |controller|
      allow(controller).to receive_messages(captcha_enabled?: true, check_captcha!: true, render_captcha: nil)
    end
  end
end
