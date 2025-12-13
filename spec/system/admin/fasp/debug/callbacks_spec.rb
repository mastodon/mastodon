# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Debug FASP Callback Management', feature: :fasp do
  before { sign_in Fabricate(:admin_user) }

  describe 'Viewing and deleting callbacks' do
    let(:provider) { Fabricate(:fasp_provider, name: 'debug prov') }

    before do
      Fabricate(:fasp_debug_callback, fasp_provider: provider, request_body: 'called back')
    end

    it 'displays callbacks and allows to delete them' do
      visit admin_fasp_debug_callbacks_path

      expect(page).to have_css('h2', text: I18n.t('admin.fasp.debug.callbacks.title'))
      expect(page).to have_css('td', text: 'debug prov')
      expect(page).to have_css('code', text: 'called back')

      expect do
        click_on I18n.t('admin.fasp.debug.callbacks.delete')

        expect(page).to have_css('h2', text: I18n.t('admin.fasp.debug.callbacks.title'))
      end.to change(Fasp::DebugCallback, :count).by(-1)
    end
  end
end
