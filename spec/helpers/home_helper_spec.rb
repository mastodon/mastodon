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

  describe 'obscured_counter' do
    context 'with a value of less than zero' do
      let(:count) { -10 }

      it 'returns the correct string' do
        expect(helper.obscured_counter(count)).to eq '0'
      end
    end

    context 'with a value of zero' do
      let(:count) { 0 }

      it 'returns the correct string' do
        expect(helper.obscured_counter(count)).to eq '0'
      end
    end

    context 'with a value of one' do
      let(:count) { 1 }

      it 'returns the correct string' do
        expect(helper.obscured_counter(count)).to eq '1'
      end
    end

    context 'with a value of more than one' do
      let(:count) { 10 }

      it 'returns the correct string' do
        expect(helper.obscured_counter(count)).to eq '1+'
      end
    end
  end

  describe 'custom_field_classes' do
    context 'with a verified field' do
      let(:field) { instance_double(Account::Field, verified?: true) }

      it 'returns verified string' do
        result = helper.custom_field_classes(field)
        expect(result).to eq 'verified'
      end
    end

    context 'with a non-verified field' do
      let(:field) { instance_double(Account::Field, verified?: false) }

      it 'returns verified string' do
        result = helper.custom_field_classes(field)
        expect(result).to eq 'emojify'
      end
    end
  end
end
