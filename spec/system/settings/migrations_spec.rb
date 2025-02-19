# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Migrations' do
  describe 'Viewing settings migrations' do
    let(:user) { Fabricate(:account, moved_to_account: moved_to_account).user }

    before { sign_in(user) }

    context 'when user does not have moved to account' do
      let(:moved_to_account) { nil }

      it 'renders show page' do
        visit settings_migration_path

        expect(page)
          .to have_content(I18n.t('settings.migrate'))
      end
    end

    context 'when user has a moved to account' do
      let(:moved_to_account) { Fabricate(:account) }

      it 'renders show page and account details' do
        visit settings_migration_path

        expect(page)
          .to have_content(I18n.t('settings.migrate'))
          .and have_content(moved_to_account.pretty_acct)
      end
    end
  end

  describe 'Creating migrations' do
    let(:user) { Fabricate(:user, password: '12345678') }

    before { sign_in(user) }

    context 'when migration account is changed' do
      let(:acct) { Fabricate(:account, also_known_as: [ActivityPub::TagManager.instance.uri_for(user.account)]) }

      it 'updates moved to account' do
        visit settings_migration_path

        expect { fill_in_and_submit }
          .to(change { user.account.reload.moved_to_account_id }.to(acct.id))
        expect(page)
          .to have_content(I18n.t('settings.migrate'))
      end
    end

    context 'when acct is the current account' do
      let(:acct) { user.account }

      it 'does not update the moved account', :aggregate_failures do
        visit settings_migration_path

        expect { fill_in_and_submit }
          .to_not(change { user.account.reload.moved_to_account_id }.from(nil))
        expect(page)
          .to have_content(I18n.t('settings.migrate'))
      end
    end

    context 'when target account does not reference the account being moved from' do
      let(:acct) { Fabricate(:account, also_known_as: []) }

      it 'does not update the moved account', :aggregate_failures do
        visit settings_migration_path

        expect { fill_in_and_submit }
          .to_not(change { user.account.reload.moved_to_account_id }.from(nil))
        expect(page)
          .to have_content(I18n.t('settings.migrate'))
      end
    end

    context 'when a recent migration already exists' do
      let(:acct) { Fabricate(:account, also_known_as: [ActivityPub::TagManager.instance.uri_for(user.account)]) }
      let(:moved_to) { Fabricate(:account, also_known_as: [ActivityPub::TagManager.instance.uri_for(user.account)]) }

      before { user.account.migrations.create!(acct: moved_to.acct) }

      it 'can not update the moved account', :aggregate_failures do
        visit settings_migration_path

        expect(find_by_id('account_migration_acct'))
          .to be_disabled
      end
    end

    def fill_in_and_submit
      fill_in 'account_migration_acct', with: acct.username
      fill_in 'account_migration_current_password', with: '12345678'
      click_on I18n.t('migrations.proceed_with_move')
    end
  end
end
