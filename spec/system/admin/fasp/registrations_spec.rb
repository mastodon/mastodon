# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FASP registration', feature: :fasp do
  include ProviderRequestHelper

  before { sign_in Fabricate(:admin_user) }

  describe 'Confirming an unconfirmed FASP' do
    let(:provider) { Fabricate(:fasp_provider, confirmed: false) }

    before do
      stub_provider_request(provider,
                            path: '/provider_info',
                            response_body: {
                              capabilities: [
                                { id: 'debug', version: '0.1' },
                              ],
                              contactEmail: 'newcontact@example.com',
                              fediverseAccount: '@newfedi@social.example.com',
                              privacyPolicy: 'https::///example.com/privacy',
                              signInUrl: 'https://myprov.example.com/sign_in',
                            })
    end

    it 'displays key fingerprint and updates the provider on confirmation' do
      visit new_admin_fasp_provider_registration_path(provider)

      expect(page).to have_css('code', text: provider.provider_public_key_fingerprint)

      click_on I18n.t('admin.fasp.providers.registrations.confirm')

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.edit'))

      expect(provider.reload).to be_confirmed
    end
  end
end
