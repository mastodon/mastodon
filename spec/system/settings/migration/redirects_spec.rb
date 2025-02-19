# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Migration Redirects' do
  let!(:user) { Fabricate(:user, password: 'testtest') }

  before { sign_in(user) }

  describe 'Managing redirects' do
    before { stub_resolver }

    it 'creates and destroys redirects' do
      visit new_settings_migration_redirect_path
      expect(page)
        .to have_title(I18n.t('settings.migrate'))

      # Empty form invalid submission
      expect { click_on I18n.t('migrations.set_redirect') }
        .to_not(change { user.account.moved_to_account_id }.from(nil))

      # Valid form submission
      fill_in 'form_redirect_acct', with: 'new@example.host'
      fill_in 'form_redirect_current_password', with: 'testtest'
      expect { click_on I18n.t('migrations.set_redirect') }
        .to(change { user.reload.account.moved_to_account_id }.from(nil))

      # Delete the account move
      expect { click_on I18n.t('migrations.cancel') }
        .to(change { user.reload.account.moved_to_account_id }.to(nil))
      expect(page)
        .to have_content(I18n.t('migrations.cancelled_msg'))
    end

    private

    def stub_resolver
      resolver = instance_double(ResolveAccountService, call: Fabricate(:account))
      allow(ResolveAccountService).to receive(:new).and_return(resolver)
    end
  end
end
