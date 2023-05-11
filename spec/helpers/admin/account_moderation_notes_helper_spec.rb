# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AccountModerationNotesHelper do
  include AccountsHelper

  describe '#admin_account_link_to' do
    context 'when Account is nil' do
      let(:account) { nil }

      it 'returns nil' do
        expect(helper.admin_account_link_to(account)).to be_nil
      end
    end

    context 'with account' do
      let(:account) { Fabricate(:account) }

      it 'calls #link_to' do
        expect(helper).to receive(:link_to).with(
          admin_account_path(account.id),
          class: name_tag_classes(account),
          title: account.acct
        )

        helper.admin_account_link_to(account)
      end
    end
  end

  describe '#admin_account_inline_link_to' do
    context 'when Account is nil' do
      let(:account) { nil }

      it 'returns nil' do
        expect(helper.admin_account_inline_link_to(account)).to be_nil
      end
    end

    context 'with account' do
      let(:account) { Fabricate(:account) }

      it 'calls #link_to' do
        result = helper.admin_account_inline_link_to(account)

        expect(result).to match(name_tag_classes(account, true))
        expect(result).to match(account.acct)
        expect(result).to match(admin_account_path(account.id))
      end
    end
  end
end
