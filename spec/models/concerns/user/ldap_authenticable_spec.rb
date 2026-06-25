# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::LdapAuthenticable do
  describe '::ldap_options' do
    subject { User.ldap_options }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    context 'when `Devise.ldap_method` is `simple_tls`' do
      before do
        Devise.ldap_method = :simple_tls
      end

      after do
        Devise.ldap_method = nil
      end

      it 'includes `encryption` key' do
        expect(subject).to have_key :encryption
      end

      context 'when `Devise.ldap_tls_no_verify` is set to `true`' do
        before do
          Devise.ldap_tls_no_verify = true
        end

        after do
          Devise.ldap_tls_no_verify = false
        end

        it 'sets `verify_mode` correctly' do
          expect(subject[:encryption][:tls_options][:verify_mode]).to eq OpenSSL::SSL::VERIFY_NONE
        end
      end
    end
  end
end
