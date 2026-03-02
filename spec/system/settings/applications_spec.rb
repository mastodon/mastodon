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
      expect(page)
        .to have_content(I18n.t('doorkeeper.applications.index.title'))
        .and have_content('My new app')
        .and have_content('read')
        .and have_content('write')
        .and have_content('follow')
    end

    it 'does not save with invalid form values' do
      visit new_settings_application_path

      expect { submit_form }
        .to not_change(Doorkeeper::Application, :count)
      expect(page)
        .to have_content("can't be blank")
    end

    def fill_in_form
      fill_in form_app_name_label,
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

  describe 'Updating an application' do
    it 'successfully updates with valid values' do
      visit settings_application_path(application)

      fill_in form_app_name_label,
              with: 'My new app name with a new value'
      check 'push', id: :doorkeeper_application_scopes_push
      submit_form

      expect(page)
        .to have_content('My new app name with a new value')
        .and have_checked_field('push', id: :doorkeeper_application_scopes_push)
    end

    it 'does not update with wrong values' do
      visit settings_application_path(application)

      fill_in form_app_name_label,
              with: ''
      submit_form

      expect(page)
        .to have_content("can't be blank")
    end

    def submit_form
      click_on(submit_button)
    end
  end

  describe 'Destroying an application' do
    let(:redis_pipeline_stub) { instance_double(Redis::PipelinedConnection, publish: nil) }
    let!(:access_token) { Fabricate(:accessible_access_token, application: application) }

    before do
      # Disable wrapstodon to avoid redis calls that we don't want to stub
      Setting.wrapstodon = false

      stub_redis_pipeline
    end

    it 'destroys the record and tells the broader universe about that' do
      visit settings_applications_path

      expect { destroy_application }
        .to change(Doorkeeper::Application, :count).by(-1)
      expect(page)
        .to have_no_content(application.name)
      expect(redis_pipeline_stub)
        .to have_received(:publish).with("timeline:access_token:#{access_token.id}", '{"event":"kill"}')
    end

    def destroy_application
      click_on I18n.t('doorkeeper.applications.index.delete')
    end

    def stub_redis_pipeline
      allow(redis)
        .to receive(:pipelined)
        .and_yield(redis_pipeline_stub)
    end
  end

  describe 'Regenerating an app token' do
    it 'updates the app token' do
      expect { visit settings_application_path(application) }
        .to change(user_application_token, :first).from(be_nil).to(be_present)

      expect { regenerate_token }
        .to(change { user_application_token.first.token })
      expect(page)
        .to have_content(I18n.t('applications.token_regenerated'))
    end

    def user_application_token
      Doorkeeper::AccessToken.where(application:).where(resource_owner_id: user)
    end

    def regenerate_token
      click_on I18n.t('applications.regenerate_token')
    end
  end

  def form_app_name_label
    I18n.t('activerecord.attributes.doorkeeper/application.name')
  end
end
