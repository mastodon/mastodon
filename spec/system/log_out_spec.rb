# frozen_string_literal: true

require 'rails_helper'

describe 'Log out' do
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

      expect(page).to have_title(I18n.t('auth.login'))
      expect(page).to have_current_path('/auth/sign_in')
    end
  end

  describe 'Logging out from the JS app', :js, :streaming do
    it 'logs the user out' do
      visit root_path

      within '.navigation-bar' do
        click_on 'Menu'
      end

      within '.dropdown-menu' do
        click_on 'Logout'
      end

      click_on 'Log out'

      expect(page).to have_title(I18n.t('auth.login'))
      expect(page).to have_current_path('/auth/sign_in')
    end
  end
end
