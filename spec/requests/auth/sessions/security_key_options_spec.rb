# frozen_string_literal: true

require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe 'Security Key Options' do
  describe 'GET /auth/sessions/security_key_options' do
    let!(:user) do
      Fabricate(:user, email: 'x@y.com', password: 'abcdefgh', otp_required_for_login: true, otp_secret: User.generate_otp_secret)
    end

    context 'with WebAuthn and OTP enabled as second factor' do
      let(:domain) { "#{Rails.configuration.x.use_https ? 'https' : 'http'}://#{Rails.configuration.x.web_domain}" }

      let(:fake_client) { WebAuthn::FakeClient.new(domain) }
      let(:public_key_credential) { WebAuthn::Credential.from_create(fake_client.create) }

      before do
        user.update(webauthn_id: WebAuthn.generate_user_id)
        Fabricate(
          :webauthn_credential,
          user_id: user.id,
          external_id: public_key_credential.id,
          public_key: public_key_credential.public_key
        )
        post '/auth/sign_in', params: { user: { email: user.email, password: user.password } }
      end

      it 'returns http success' do
        get '/auth/sessions/security_key_options'

        expect(response)
          .to have_http_status 200
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when WebAuthn not enabled' do
      it 'returns http unauthorized' do
        get '/auth/sessions/security_key_options'

        expect(response)
          .to have_http_status 401
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
