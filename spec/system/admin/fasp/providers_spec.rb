# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FASP Management', feature: :fasp do
  include ActionView::RecordIdentifier
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
    let(:callback_capability) do
      provider.fasp_capabilities.find_by(name: 'callback')
    end

    it 'allows enabling and disabling of capabilities' do
      visit admin_fasp_providers_path

      expect(page).to have_css('h1', text: I18n.t('admin.fasp.providers.title'))
      expect(page).to have_css('td', text: provider.name)

      click_on I18n.t('admin.fasp.providers.edit')

      expect(page).to have_css('h1', text: I18n.t('admin.fasp.providers.edit'))

      within css_id(callback_capability) do
        click_on I18n.t('admin.fasp.capabilities.enable')
      end

      expect(provider.reload).to be_capability_enabled('callback')
      expect(enable_call).to have_been_requested

      expect(page).to have_css('h1', text: I18n.t('admin.fasp.providers.edit'))

      within css_id(callback_capability) do
        click_on I18n.t('admin.fasp.capabilities.disable')
      end

      expect(provider.reload).to_not be_capability_enabled('callback')
      expect(disable_call).to have_been_requested
    end
  end

  describe 'Removing a provider' do
    let!(:provider) { Fabricate(:fasp_provider) }

    it 'allows to completely remove a provider' do
      visit admin_fasp_providers_path

      expect(page).to have_css('h1', text: I18n.t('admin.fasp.providers.title'))
      expect(page).to have_css('td', text: provider.name)

      click_on I18n.t('admin.fasp.providers.delete')

      expect(page).to have_css('h1', text: I18n.t('admin.fasp.providers.title'))
      expect(page).to have_no_css('td', text: provider.name)
    end
  end
end
