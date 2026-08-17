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
      let(:account) { Fabricate.build(:account) }

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

  describe 'field_verified_class' do
    subject { helper.field_verified_class(verified) }

    context 'with a verified field' do
      let(:verified) { true }

      it { is_expected.to eq('verified') }
    end

    context 'with a non-verified field' do
      let(:verified) { false }

      it { is_expected.to eq('emojify') }
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
