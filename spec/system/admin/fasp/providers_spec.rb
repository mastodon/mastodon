# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FASP Management', feature: :fasp do
  include ProviderRequestHelper

  before { sign_in Fabricate(:admin_user) }

  describe 'Managing capabilities' do
    let!(:provider) { Fabricate(:confirmed_fasp) }
    let!(:enable_call) do
      stub_provider_request(provider,
                            method: :post,
                            path: '/capabilities/callback/0/activation')
    end
    let!(:disable_call) do
      stub_provider_request(provider,
                            method: :delete,
                            path: '/capabilities/callback/0/activation')
    end

    before do
      # We currently err on the side of caution and prefer to send
      # a "disable capability" call too often over risking to miss
      # one. So the following call _can_ happen here, and if it does
      # that is fine, but it has no bearing on the behavior that is
      # being tested.
      stub_provider_request(provider,
                            method: :delete,
                            path: '/capabilities/data_sharing/0/activation')
    end

    it 'allows enabling and disabling of capabilities' do
      visit admin_fasp_providers_path

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.title'))
      expect(page).to have_css('td', text: provider.name)

      click_on I18n.t('admin.fasp.providers.edit')

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.edit'))

      check 'callback'

      click_on I18n.t('admin.fasp.providers.save')

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.title'))
      expect(provider.reload).to be_capability_enabled('callback')
      expect(enable_call).to have_been_requested

      click_on I18n.t('admin.fasp.providers.edit')

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.edit'))

      uncheck 'callback'

      click_on I18n.t('admin.fasp.providers.save')

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.title'))
      expect(provider.reload).to_not be_capability_enabled('callback')
      expect(disable_call).to have_been_requested
    end
  end

  describe 'Removing a provider' do
    let!(:provider) { Fabricate(:fasp_provider) }

    it 'allows to completely remove a provider' do
      visit admin_fasp_providers_path

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.title'))
      expect(page).to have_css('td', text: provider.name)

      click_on I18n.t('admin.fasp.providers.delete')

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.title'))
      expect(page).to have_no_css('td', text: provider.name)
    end
  end
end
