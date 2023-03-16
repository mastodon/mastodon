# frozen_string_literal: true

module Settings
  module TwoFactorAuthentication
    class WebauthnCredentialsController < BaseController
      skip_before_action :require_functional!

      before_action :require_otp_enabled
      before_action :require_webauthn_enabled, only: [:index, :destroy]

      def new; end

      def index; end

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
            status = :ok

            if current_user.webauthn_credentials.size == 1
              UserMailer.webauthn_enabled(current_user).deliver_later!
            else
              UserMailer.webauthn_credential_added(current_user, user_credential).deliver_later!
            end
          else
            flash[:error] = I18n.t('webauthn_credentials.create.error')
            status = :unprocessable_entity
          end
        else
          flash[:error] = t('webauthn_credentials.create.error')
          status = :unauthorized
        end

        render json: { redirect_path: settings_two_factor_authentication_methods_path }, status: status
      end

      def destroy
        credential = current_user.webauthn_credentials.find_by(id: params[:id])
        if credential
          credential.destroy
          if credential.destroyed?
            flash[:success] = I18n.t('webauthn_credentials.destroy.success')

            if current_user.webauthn_credentials.empty?
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

      def set_pack
        use_pack 'auth'
      end

      def require_otp_enabled
        unless current_user.otp_enabled?
          flash[:error] = t('webauthn_credentials.otp_required')
          redirect_to settings_two_factor_authentication_methods_path
        end
      end

      def require_webauthn_enabled
        unless current_user.webauthn_enabled?
          flash[:error] = t('webauthn_credentials.not_enabled')
          redirect_to settings_two_factor_authentication_methods_path
        end
      end
    end
  end
end
