# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthentication::RecoveryCodesController do
  render_views

  let(:user) { Fabricate(:user) }

  describe 'POST #create' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      it 'updates the codes and shows them on a view with correct password and code' do
        otp_backup_codes = user.generate_otp_backup_codes!

        expect_any_instance_of(User).to receive(:valid_password?) do |value, arg|
          expect(value).to eq user
          expect(arg).to eq '123456789'
          true
        end

        expect_any_instance_of(User).to receive(:validate_and_consume_otp!) do |value, arg|
          expect(value).to eq user
          expect(arg).to eq '123456'
          true
        end

        expect_any_instance_of(User).to receive(:generate_otp_backup_codes!) do |value|
          expect(value).to eq user
          otp_backup_codes
        end

        expect_any_instance_of(UserMailer).to receive(:recovery_codes_regenerated) do |_, arg|
          expect(arg).to eq user
        end

        post :create, params: { form_recovery_code_confirmation: { password: '123456789', code: '123456' } }

        expect(assigns(:recovery_codes)).to eq otp_backup_codes
        expect(flash[:notice]).to eq 'Recovery codes successfully regenerated'
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end

      it 'does not update the codes with incorrect password' do
        expect_any_instance_of(User).to receive(:valid_password?) do |value, arg|
          expect(value).to eq user
          expect(arg).to eq 'hunter2'
          false
        end

        expect_any_instance_of(User).to receive(:validate_and_consume_otp!) do |value, arg|
          expect(value).to eq user
          expect(arg).to eq '123456'
          true
        end

        post :create, params: { form_recovery_code_confirmation: { password: 'hunter2', code: '123456' } }

        expect(assigns(:recovery_codes)).to be_nil
        expect(response).to redirect_to settings_two_factor_authentication_path
      end

      it 'does not update the codes with incorrect code' do
        expect_any_instance_of(User).to receive(:valid_password?) do |value, arg|
          expect(value).to eq user
          expect(arg).to eq '123456789'
          true
        end

        expect_any_instance_of(User).to receive(:validate_and_consume_otp!) do |value, arg|
          expect(value).to eq user
          expect(arg).to eq '057772'
          false
        end

        post :create, params: { form_recovery_code_confirmation: { password: '123456789', code: '057772' } }

        expect(assigns(:recovery_codes)).to be_nil
        expect(response).to redirect_to settings_two_factor_authentication_path
      end

      it 'raises ActionController::ParameterMissing if password is missing' do
        expect { post :create }.to raise_error(ActionController::ParameterMissing)
      end
    end

    it 'redirects when not signed in' do
      post :create
      expect(response).to redirect_to '/auth/sign_in'
    end
  end
end
