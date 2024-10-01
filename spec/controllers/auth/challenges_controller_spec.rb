# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::ChallengesController do
  render_views

  let(:password) { 'foobar12345' }
  let(:user) { Fabricate(:user, password: password) }

  before do
    sign_in user
  end

  describe 'POST #create' do
    let(:return_to) { edit_user_registration_path }

    context 'with correct password' do
      before { post :create, params: { form_challenge: { return_to: return_to, current_password: password } } }

      it 'redirects back' do
        expect(response).to redirect_to(return_to)
      end

      it 'sets session' do
        expect(session[:challenge_passed_at]).to_not be_nil
      end
    end

    context 'with incorrect password' do
      before { post :create, params: { form_challenge: { return_to: return_to, current_password: 'hhfggjjd562' } } }

      it 'renders challenge' do
        expect(response).to render_template('auth/challenges/new')
      end

      it 'displays error' do
        expect(response.body).to include 'Invalid password'
      end

      it 'does not set session' do
        expect(session[:challenge_passed_at]).to be_nil
      end
    end
  end
end
