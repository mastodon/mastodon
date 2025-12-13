# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Relationships' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  describe 'Viewing account relationships page' do
    let(:account) { Fabricate(:account) }

    it 'shows page with relationships for account' do
      visit admin_account_relationships_path(account.id)

      expect(page)
        .to have_title(I18n.t('admin.relationships.title', acct: account.pretty_acct))
    end
  end
end
