# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthentication::ConfirmationsController do
  render_views

  shared_examples 'renders :new' do
    it 'renders the new view' do
      subject

      expect(assigns(:confirmation)).to be_instance_of Form::TwoFactorConfirmation
      expect(assigns(:provision_url)).to eq 'otpauth://totp/cb6e6126.ngrok.io:local-part%40domain?secret=thisisasecretforthespecofnewview&issuer=cb6e6126.ngrok.io'
      expect(assigns(:qrcode)).to be_instance_of RQRCode::QRCode
      expect(response).to have_http_status(200)
      expect(response).to render_template(:new)
    end
  end

  [true, false].each do |with_otp_secret|
    let(:user) { Fabricate(:user, email: 'local-part@domain', otp_secret: with_otp_secret ? 'oldotpsecret' : nil) }

    describe 'GET #new' do
      context 'when signed in and a new otp secret has been set in the session' do
        subject do
          sign_in user, scope: :user
          get :new, session: { challenge_passed_at: Time.now.utc, new_otp_secret: 'thisisasecretforthespecofnewview' }
        end

        include_examples 'renders :new'
      end

      it 'redirects if not signed in' do
        get :new
        expect(response).to redirect_to('/auth/sign_in')
      end

      it 'redirects if a new otp_secret has not been set in the session' do
        sign_in user, scope: :user
        get :new, session: { challenge_passed_at: Time.now.utc }
        expect(response).to redirect_to('/settings/otp_authentication')
      end
    end

    describe 'POST #create' do
      context 'when signed in' do
        before do
          sign_in user, scope: :user
        end

        describe 'when form_two_factor_confirmation parameter is not provided' do
          it 'raises ActionController::ParameterMissing' do
            post :create, params: {}, session: { challenge_passed_at: Time.now.utc, new_otp_secret: 'thisisasecretforthespecofnewview' }
            expect(response).to have_http_status(400)
          end
        end

        describe 'when creation succeeds' do
          let!(:otp_backup_codes) { user.generate_otp_backup_codes! }

          it 'renders page with success' do
            prepare_user_otp_generation
            prepare_user_otp_consumption

            expect do
              post :create,
                   params: { form_two_factor_confirmation: { otp_attempt: '123456' } },
                   session: { challenge_passed_at: Time.now.utc, new_otp_secret: 'thisisasecretforthespecofnewview' }
            end.to change { user.reload.otp_secret }.to 'thisisasecretforthespecofnewview'

            expect(assigns(:recovery_codes)).to eq otp_backup_codes
            expect(flash[:notice]).to eq 'Two-factor authentication successfully enabled'
            expect(response).to have_http_status(200)
            expect(response).to render_template('settings/two_factor_authentication/recovery_codes/index')
          end

          def prepare_user_otp_generation
            expect_any_instance_of(User).to receive(:generate_otp_backup_codes!) do |value|
              expect(value).to eq user
              otp_backup_codes
            end
          end

          def prepare_user_otp_consumption
            expect_any_instance_of(User).to receive(:validate_and_consume_otp!) do |value, code, options|
              expect(value).to eq user
              expect(code).to eq '123456'
              expect(options).to eq({ otp_secret: 'thisisasecretforthespecofnewview' })
              true
            end
          end
        end

        describe 'when creation fails' do
          subject do
            expect_any_instance_of(User).to receive(:validate_and_consume_otp!) do |value, code, options|
              expect(value).to eq user
              expect(code).to eq '123456'
              expect(options).to eq({ otp_secret: 'thisisasecretforthespecofnewview' })
              false
            end

            expect do
              post :create,
                   params: { form_two_factor_confirmation: { otp_attempt: '123456' } },
                   session: { challenge_passed_at: Time.now.utc, new_otp_secret: 'thisisasecretforthespecofnewview' }
            end.to not_change { user.reload.otp_secret }
          end

          it 'renders the new view' do
            subject
            expect(response.body).to include 'The entered code was invalid! Are server time and device time correct?'
          end

          include_examples 'renders :new'
        end
      end

      context 'when not signed in' do
        it 'redirects if not signed in' do
          post :create, params: { form_two_factor_confirmation: { otp_attempt: '123456' } }
          expect(response).to redirect_to('/auth/sign_in')
        end
      end
    end
  end
end
