# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeHelper, type: :helper do
  describe 'default_props' do
    it 'returns default properties according to the context' do
      expect(helper.default_props).to eq locale: I18n.locale
    end
  end

  describe 'account_link_to' do
    context 'with a missing account' do
      let(:account) { nil }

      it 'returns a button' do
        result = helper.account_link_to(account)

        expect(result).to match t('about.contact_missing')
      end
    end

    context 'with a valid account' do
      let(:account) { Fabricate(:account) }

      it 'returns a link to the account' do
        without_partial_double_verification do
          allow(helper).to receive(:current_account).and_return(account)
          allow(helper).to receive(:prefers_autoplay?).and_return(false)
          result = helper.account_link_to(account)

          expect(result).to match "@#{account.acct}"
        end
      end
    end
  end
end
