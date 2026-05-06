# frozen_string_literal: true

require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe 'Security Key Options' do
  describe 'GET /auth/sessions/security_key_options' do
    subject { get '/auth/sessions/security_key_options' }

    let!(:user) { Fabricate(:user, email: 'x@y.com', password: 'abcdefgh', otp_required_for_login: true, otp_secret: User.generate_otp_secret) }

    context 'with WebAuthn and OTP enabled as second factor' do
      let(:domain) { "#{Rails.configuration.x.use_https ? 'https' : 'http'}://#{Rails.configuration.x.web_domain}" }

      let(:fake_client) { WebAuthn::FakeClient.new(domain) }
      let(:public_key_credential) { WebAuthn::Credential.from_create(fake_client.create) }

      before do
        user.update(webauthn_id: WebAuthn.generate_user_id)
        Fabricate(
          :webauthn_credential,
          external_id: public_key_credential.id,
          public_key: public_key_credential.public_key,
          user_id: user.id
        )
      end

      context 'when signed in' do
        before { post '/auth/sign_in', params: { user: { email: user.email, password: user.password } } }

        it 'returns http success' do
          subject

          expect(response)
            .to have_http_status 200
          expect(response.media_type)
            .to eq('application/json')
          expect(response.parsed_body)
            .to include(
              challenge: be_present,
              userVerification: eq('discouraged'),
              allowCredentials: contain_exactly(include(type: 'public-key', id: be_present))
            )
        end
      end

      context 'when not signed in' do
        it 'returns http unauthorized' do
          subject

          expect(response)
            .to have_http_status 401
          expect(response.media_type)
            .to eq('application/json')
          expect(response.parsed_body)
            .to include(error: I18n.t('webauthn_credentials.not_enabled'))
        end
      end
    end

    context 'when WebAuthn not enabled' do
      it 'returns http unauthorized' do
        subject

        expect(response)
          .to have_http_status 401
        expect(response.media_type)
          .to eq('application/json')
        expect(response.parsed_body)
          .to include(error: I18n.t('webauthn_credentials.not_enabled'))
      end
    end
  end
end
