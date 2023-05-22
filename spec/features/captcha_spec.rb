# frozen_string_literal: true

require 'rails_helper'

describe 'email confirmation flow when captcha is enabled' do
  let(:user)        { Fabricate(:user, confirmed_at: nil, confirmation_token: 'foobar', created_by_application: client_app) }
  let(:client_app)  { nil }

  before do
    # rubocop:disable RSpec/AnyInstance -- easiest way to deal with that that I know of
    allow_any_instance_of(Auth::ConfirmationsController).to receive(:captcha_enabled?).and_return(true)
    allow_any_instance_of(Auth::ConfirmationsController).to receive(:check_captcha!).and_return(true)
    allow_any_instance_of(Auth::ConfirmationsController).to receive(:render_captcha).and_return(nil)
    # rubocop:enable RSpec/AnyInstance
  end

  context 'when the user signed up through an app' do
    let(:client_app) { Fabricate(:application) }

    it 'logs in' do
      visit "/auth/confirmation?confirmation_token=#{user.confirmation_token}&redirect_to_app=true"

      # It presents the user with a captcha form
      expect(page).to have_title(I18n.t('auth.captcha_confirmation.title'))

      # It does not confirm the user just yet
      expect(user.reload.confirmed?).to be false

      # It redirects to app and confirms user
      click_on I18n.t('challenge.confirm')
      expect(user.reload.confirmed?).to be true
      expect(page).to have_current_path(/\A#{client_app.confirmation_redirect_uri}/, url: true)
    end
  end
end
