# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Sessions' do
  let(:user) { Fabricate(:user) }
  let!(:session_activation) { Fabricate(:session_activation, user: user) }

  before { sign_in(user) }

  describe 'deleting a session' do
    it 'deletes listed session activation from the auth page' do
      visit edit_user_registration_path
      expect(page)
        .to have_title(I18n.t('settings.account_settings'))

      expect { click_on(I18n.t('sessions.revoke')) }
        .to change(SessionActivation, :count).by(-1)
      expect { session_activation.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(page)
        .to have_content(I18n.t('sessions.revoke_success'))
    end
  end
end
