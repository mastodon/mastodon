# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login activities page' do
  let!(:user) { Fabricate :user }
  let!(:login_activity) { Fabricate :login_activity, user: user }

  context 'when signed in' do
    before { sign_in user }

    describe 'Viewing the login activities page' do
      it 'shows the login activity history' do
        visit edit_user_registration_path

        click_on I18n.t('sessions.view_authentication_history')

        expect(page)
          .to have_content(browser_description)
          .and have_content(login_activity.authentication_method)
          .and have_content(login_activity.ip)
          .and have_private_cache_control
      end

      def browser_description
        I18n.t(
          'sessions.description',
          browser: I18n.t("sessions.browsers.#{login_activity.browser}", default: login_activity.browser),
          platform: I18n.t("sessions.platforms.#{login_activity.platform}", default: login_activity.platform)
        )
      end
    end
  end
end
