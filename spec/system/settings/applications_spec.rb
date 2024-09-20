# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings applications page' do
  let!(:application) { Fabricate :application, owner: user }
  let(:user) { Fabricate :user }

  before { sign_in user }

  describe 'Viewing the list of applications' do
    it 'sees the applications' do
      visit settings_applications_path

      expect(page)
        .to have_content(application.name)
        .and have_private_cache_control
    end
  end

  describe 'Viewing a single application' do
    it 'shows a page with application details' do
      visit settings_application_path(application)

      expect(page)
        .to have_content(application.name)
    end
  end

  describe 'Creating a new application' do
    it 'accepts form input to make an application' do
      visit new_settings_application_path

      fill_in_form

      expect { submit_form }
        .to change(Doorkeeper::Application, :count).by(1)
    end

    it 'does not save with invalid form values' do
      visit new_settings_application_path

      expect { submit_form }
        .to not_change(Doorkeeper::Application, :count)
      expect(page)
        .to have_content("can't be blank")
    end

    def fill_in_form
      fill_in I18n.t('activerecord.attributes.doorkeeper/application.name'),
              with: 'My new app'
      fill_in I18n.t('activerecord.attributes.doorkeeper/application.website'),
              with: 'http://google.com'
      fill_in I18n.t('activerecord.attributes.doorkeeper/application.redirect_uri'),
              with: 'urn:ietf:wg:oauth:2.0:oob'

      check 'read', id: :doorkeeper_application_scopes_read
      check 'write', id: :doorkeeper_application_scopes_write
      check 'follow', id: :doorkeeper_application_scopes_follow
    end

    def submit_form
      click_on I18n.t('doorkeeper.applications.buttons.submit')
    end
  end
end
