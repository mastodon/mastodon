# frozen_string_literal: true

module Settings
  module TwoFactorAuthentication
    class WebauthnCredentialsController < BaseController
      skip_before_action :require_functional!

      before_action :require_webauthn_enabled, only: [:index, :destroy]

      def index; end
      def new; end

      def options
        current_user.update(webauthn_id: WebAuthn.generate_user_id) unless current_user.webauthn_id

        options_for_create = WebAuthn::Credential.options_for_create(
          user: {
            name: current_user.account.username,
            display_name: current_user.account.username,
            id: current_user.webauthn_id,
          },
          exclude: current_user.webauthn_credentials.pluck(:external_id),
          authenticator_selection: { user_verification: 'discouraged' }
        )

        session[:webauthn_challenge] = options_for_create.challenge

        render json: options_for_create, status: 200
      end

      def create
        webauthn_credential = WebAuthn::Credential.from_create(params[:credential])

        if webauthn_credential.verify(session[:webauthn_challenge])
          user_credential = current_user.webauthn_credentials.build(
            external_id: webauthn_credential.id,
            public_key: webauthn_credential.public_key,
            nickname: params[:nickname],
            sign_count: webauthn_credential.sign_count
          )

          if user_credential.save
            flash[:success] = I18n.t('webauthn_credentials.create.success')

            generated_otp_backup_codes = false
            unless current_user.otp_backup_codes?
              current_user.otp_secret = User.generate_otp_secret(32)
              recovery_codes = current_user.generate_otp_backup_codes!
              current_user.save!

              generated_otp_backup_codes = true
            end

            if current_user.webauthn_credentials.size == 1
              UserMailer.webauthn_enabled(current_user).deliver_later!
            else
              UserMailer.webauthn_credential_added(current_user, user_credential).deliver_later!
            end

            if generated_otp_backup_codes
              render json: {
                html_data:
                  render_to_string(
                    partial: 'settings/two_factor_authentication/webauthn_credentials/recovery_codes',
                    locals: { recovery_codes: recovery_codes },
                    formats: :html,
                    layout: false
                  ),
                status: :ok,
              }
            else
              render json: { redirect_path: settings_two_factor_authentication_methods_path }, status: 200
            end
          else
            flash[:error] = I18n.t('webauthn_credentials.create.error')

            render json: { redirect_path: settings_two_factor_authentication_methods_path }, status: 422
          end
        else
          flash[:error] = t('webauthn_credentials.create.error')

          render json: { redirect_path: settings_two_factor_authentication_methods_path }, status: 401
        end
      end

      def destroy
        credential = current_user.webauthn_credentials.find_by(id: params[:id])
        if credential
          credential.destroy
          if credential.destroyed?
            flash[:success] = I18n.t('webauthn_credentials.destroy.success')

            if !current_user.otp_enabled? && current_user.webauthn_credentials.empty?
              current_user.disable_two_factor!
              UserMailer.two_factor_disabled(current_user).deliver_later!
            elsif current_user.webauthn_credentials.empty?
              UserMailer.webauthn_disabled(current_user).deliver_later!
            else
              UserMailer.webauthn_credential_deleted(current_user, credential).deliver_later!
            end
          else
            flash[:error] = I18n.t('webauthn_credentials.destroy.error')
          end
        else
          flash[:error] = I18n.t('webauthn_credentials.destroy.error')
        end
        redirect_to settings_two_factor_authentication_methods_path
      end

      private

      def require_webauthn_enabled
        unless current_user.webauthn_enabled?
          flash[:error] = t('webauthn_credentials.not_enabled')
          redirect_to settings_two_factor_authentication_methods_path
        end
      end
    end
  end
end
