# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Challenges' do
  let(:password) { 'foobar12345' }
  let(:user) { Fabricate(:user, password: password) }

  before { sign_in user }

  describe 'POST #create' do
    let(:return_to) { edit_user_registration_path }

    context 'with correct password' do
      it 'redirects back and sets challenge passed at in session' do
        post '/auth/challenge', params: { form_challenge: { return_to: return_to, current_password: password } }

        expect(response)
          .to redirect_to(return_to)
        expect(session[:challenge_passed_at])
          .to_not be_nil
      end
    end

    context 'with incorrect password' do
      it 'renders challenge, displays error, does not set session' do
        post '/auth/challenge', params: { form_challenge: { return_to: return_to, current_password: 'hhfggjjd562' } }

        expect(response.body)
          .to include(I18n.t('challenge.prompt'))
          .and include('Invalid password')
        expect(session[:challenge_passed_at])
          .to be_nil
      end
    end

    context 'with invalid params' do
      it 'gracefully handles invalid nested params' do
        post auth_challenge_path(form_challenge: 'invalid')

        expect(response)
          .to have_http_status(400)
      end
    end
  end
end
