# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FASP Debug Calls', feature: :fasp do
  include ProviderRequestHelper

  before { sign_in Fabricate(:admin_user) }

  describe 'Triggering a FASP debug call' do
    let!(:provider) { Fabricate(:debug_fasp) }
    let!(:debug_call) do
      stub_provider_request(provider,
                            method: :post,
                            path: '/debug/v0/callback/logs',
                            response_status: 201)
    end

    it 'makes a debug call to the provider' do
      visit admin_fasp_providers_path

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.title'))
      expect(page).to have_css('td', text: provider.name)

      within 'table#providers' do
        click_on I18n.t('admin.fasp.providers.callback')
      end

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.providers.title'))
      expect(debug_call).to have_been_requested
    end
  end
end
