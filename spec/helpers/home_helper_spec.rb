# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeHelper do
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

      before { helper.extend controller_helpers }

      it 'returns a link to the account' do
        result = helper.account_link_to(account)

        expect(result).to match "@#{account.acct}"
      end

      private

      def controller_helpers
        Module.new do
          def current_account = Account.last
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

  describe 'sign_up_messages' do
    context 'with closed registrations' do
      it 'returns correct sign up message' do
        allow(helper).to receive(:closed_registrations?).and_return(true)
        result = helper.sign_up_message

        expect(result).to eq t('auth.registration_closed', instance: local_domain_uri.host)
      end
    end

    context 'with open registrations' do
      it 'returns correct sign up message' do
        allow(helper).to receive_messages(closed_registrations?: false, open_registrations?: true)
        result = helper.sign_up_message

        expect(result).to eq t('auth.register')
      end
    end

    context 'with approved registrations' do
      it 'returns correct sign up message' do
        allow(helper).to receive_messages(closed_registrations?: false, open_registrations?: false, approved_registrations?: true)
        result = helper.sign_up_message

        expect(result).to eq t('auth.apply_for_account')
      end
    end
  end
end
