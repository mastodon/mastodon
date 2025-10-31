# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Log out' do
  include ProfileStories

  before do
    as_a_logged_in_user
  end

  describe 'Logging out from the preferences' do
    it 'logs the user out' do
      visit settings_path

      within '.sidebar' do
        click_on 'Logout'
      end

      expect(page)
        .to have_title(I18n.t('auth.login'))
        .and have_current_path('/auth/sign_in')
    end
  end

  describe 'Logging out from the JS app', :js, :streaming do
    it 'logs the user out' do
      # The frontend tries to load announcements after a short delay, but the session might be expired by then, and the browser will output an error.
      ignore_js_error(/Failed to load resource: the server responded with a status/)

      visit root_path
      expect(page)
        .to have_css('body', class: 'app-body')

      within '.navigation-panel' do
        click_on 'More'
      end

      within '.dropdown-menu' do
        click_on 'Logout'
      end

      click_on 'Log out'

      expect(page)
        .to have_title(I18n.t('auth.login'))
        .and have_current_path('/auth/sign_in')
    end
  end
end
