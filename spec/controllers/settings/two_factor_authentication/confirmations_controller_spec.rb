# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::TwoFactorAuthentication::ConfirmationsController do
  render_views

  shared_examples 'renders :new' do
    it 'renders the new view' do
      subject

      expect(response).to have_http_status(200)
      expect(response).to render_template(:new)
      expect(response.body)
        .to include(qr_code_markup)
    end

    def qr_code_markup
      RQRCode::QRCode.new(
        'otpauth://totp/cb6e6126.ngrok.io:local-part%40domain?secret=thisisasecretforthespecofnewview&issuer=cb6e6126.ngrok.io'
      ).as_svg(padding: 0, module_size: 4, use_path: true)
    end
  end

  [true, false].each do |with_otp_secret|
    let(:user) { Fabricate(:user, email: 'local-part@domain', otp_secret: with_otp_secret ? 'oldotpsecret' : nil) }

    context 'when signed in' do
      before { sign_in user, scope: :user }

      describe 'GET #new' do
        context 'when a new otp secret has been set in the session' do
          subject do
            get :new, session: { challenge_passed_at: Time.now.utc, new_otp_secret: 'thisisasecretforthespecofnewview' }
          end

          include_examples 'renders :new'
        end

        it 'redirects if a new otp_secret has not been set in the session' do
          get :new, session: { challenge_passed_at: Time.now.utc }

          expect(response).to redirect_to('/settings/otp_authentication')
        end
      end

      describe 'POST #create' do
        describe 'when form_two_factor_confirmation parameter is not provided' do
          it 'raises ActionController::ParameterMissing' do
            post :create, params: {}, session: { challenge_passed_at: Time.now.utc, new_otp_secret: 'thisisasecretforthespecofnewview' }

            expect(response).to have_http_status(400)
          end
        end

        describe 'when creation succeeds' do
          let!(:otp_backup_codes) { user.generate_otp_backup_codes! }

          before do
            prepare_user_otp_generation
            prepare_user_otp_consumption_response(true)
            allow(controller).to receive(:current_user).and_return(user)
          end

          it 'renders page with success' do
            expect { post_create_with_options }
              .to change { user.reload.otp_secret }.to 'thisisasecretforthespecofnewview'

            expect(flash[:notice]).to eq 'Two-factor authentication successfully enabled'
            expect(response).to have_http_status(200)
            expect(response).to render_template('settings/two_factor_authentication/recovery_codes/index')
            expect(response.body).to include(*otp_backup_codes)
          end
        end

        describe 'when creation fails' do
          subject do
            expect { post_create_with_options }
              .to(not_change { user.reload.otp_secret })
          end

          before do
            prepare_user_otp_consumption_response(false)
            allow(controller).to receive(:current_user).and_return(user)
          end

          it 'renders page with error message' do
            subject
            expect(response.body).to include 'The entered code was invalid! Are server time and device time correct?'
          end

          include_examples 'renders :new'
        end

        private

        def post_create_with_options
          post :create,
               params: { form_two_factor_confirmation: { otp_attempt: '123456' } },
               session: { challenge_passed_at: Time.now.utc, new_otp_secret: 'thisisasecretforthespecofnewview' }
        end

        def prepare_user_otp_generation
          allow(user)
            .to receive(:generate_otp_backup_codes!)
            .and_return(otp_backup_codes)
        end

        def prepare_user_otp_consumption_response(result)
          options = { otp_secret: 'thisisasecretforthespecofnewview' }
          allow(user)
            .to receive(:validate_and_consume_otp!)
            .with('123456', options)
            .and_return(result)
        end
      end
    end
  end

  context 'when not signed in' do
    it 'redirects on POST to create' do
      post :create, params: { form_two_factor_confirmation: { otp_attempt: '123456' } }

      expect(response).to redirect_to('/auth/sign_in')
    end

    it 'redirects on GET to new' do
      get :new

      expect(response).to redirect_to('/auth/sign_in')
    end
  end
end
