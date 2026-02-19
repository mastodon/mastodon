# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings aliases page' do
  let!(:user) { Fabricate(:user) }
  let(:account) { user.account }

  before { sign_in user }

  describe 'Viewing aliases' do
    it 'shows index page with private cache control headers' do
      visit settings_aliases_path

      # View index page
      expect(page)
        .to have_content(I18n.t('settings.aliases'))
        .and have_private_cache_control
    end
  end

  describe 'Creating an alias' do
    context 'with valid alias value' do
      before { stub_resolver }

      it 'creates an alias for the user' do
        visit settings_aliases_path

        fill_in 'account_alias_acct',
                with: 'new@host.example'
        expect { submit_form }
          .to change(AccountAlias, :count).by(1)
        expect(page)
          .to have_content(I18n.t('aliases.created_msg'))
      end
    end

    context 'with invalid value' do
      it 'does not create an alias for the user' do
        visit settings_aliases_path

        fill_in 'account_alias_acct',
                with: 'invalid-value'
        expect { submit_form }
          .to not_change(AccountAlias, :count)
        expect(page)
          .to have_content(I18n.t('settings.aliases'))
      end
    end

    def submit_form
      click_on I18n.t('aliases.add_new')
    end
  end

  describe 'Removing an alias' do
    let!(:account_alias) do
      AccountAlias.new(account: user.account, acct: 'new@example.com').tap do |account_alias|
        account_alias.save(validate: false)
      end
    end

    it 'removes an alias' do
      visit settings_aliases_path
      expect { click_on I18n.t('aliases.remove') }
        .to change(AccountAlias, :count).by(-1)

      expect(page)
        .to have_content(I18n.t('settings.aliases'))
        .and have_content(I18n.t('aliases.deleted_msg'))
      expect { account_alias.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  private

  def stub_resolver
    resolver = instance_double(ResolveAccountService, call: Fabricate(:account))
    allow(ResolveAccountService).to receive(:new).and_return(resolver)
  end
end
