# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MfaForceConcern do
  controller(ApplicationController) do
    def index
      render plain: 'OK'
    end
  end

  let(:user) { Fabricate(:user) }

  before do
    routes.draw { get 'index' => 'anonymous#index' }
  end

  describe 'MFA force functionality' do
    context 'when REQUIRE_MULTI_FACTOR_AUTH is enabled' do
      before do
        ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'true') do
          sign_in user, scope: :user
        end
      end

      context 'when user has MFA enabled' do
        before do
          user.update(otp_required_for_login: true)
        end

        it 'allows access to normal pages' do
          ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'true') do
            get :index
            expect(response).to have_http_status(200)
          end
        end
      end

      context 'when user does not have MFA enabled' do
        before do
          user.update(otp_required_for_login: false)
        end

        it 'redirects to MFA setup page' do
          ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'true') do
            get :index
            expect(response).to redirect_to(settings_otp_authentication_path)
          end
        end

        it 'shows the required message' do
          ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'true') do
            get :index
            expect(flash[:alert]).to eq(I18n.t('require_multi_factor_auth.required_message'))
          end
        end

        context 'when accessing MFA setup pages' do
          it 'allows access to OTP authentication page' do
            ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'true') do
              allow(controller.request).to receive(:path).and_return('/settings/otp_authentication')
              get :index
              expect(response).to have_http_status(200)
            end
          end

          it 'allows access to MFA confirmation page' do
            ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'true') do
              allow(controller.request).to receive(:path).and_return('/settings/two_factor_authentication/confirmation')
              get :index
              expect(response).to have_http_status(200)
            end
          end

          it 'allows access to logout' do
            ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'true') do
              allow(controller.request).to receive(:path).and_return('/auth/sign_out')
              get :index
              expect(response).to have_http_status(200)
            end
          end
        end
      end
    end

    context 'when REQUIRE_MULTI_FACTOR_AUTH is disabled' do
      before do
        ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'false') do
          sign_in user, scope: :user
          user.update(otp_required_for_login: false)
        end
      end

      it 'allows access to normal pages' do
        ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'false') do
          get :index
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'when user is not signed in' do
      it 'allows access to normal pages' do
        ClimateControl.modify(REQUIRE_MULTI_FACTOR_AUTH: 'true') do
          get :index
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
