# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Logging out' do
  include ProfileStories

  before { as_a_logged_in_user }

  context 'when using the preferences area' do
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

  context 'when using the JS dropdown', :js, :streaming do
    it 'logs the user out' do
      # The frontend tries to load announcements after a short delay, but the session might be expired by then, and the browser will output an error.
      ignore_js_error(/Failed to load resource: the server responded with a status of 422/)

      visit root_path
      expect(page)
        .to have_css('body', class: 'app-body')

      within '.navigation-bar' do
        click_on 'Menu'
      end
      expect(page)
        .to have_content('Logout')

      within '.dropdown-menu' do
        click_on 'Logout'
      end
      expect(page)
        .to have_content('Are you sure')

      click_on 'Log out'
      expect(page)
        .to have_title(I18n.t('auth.login'))
        .and have_current_path('/auth/sign_in')
    end
  end
end
