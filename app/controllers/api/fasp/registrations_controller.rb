# frozen_string_literal: true

class Api::Fasp::RegistrationsController < Api::Fasp::BaseController
  skip_before_action :require_authentication

  def create
    @current_provider = Fasp::Provider.create!(
      name: params[:name],
      base_url: params[:baseUrl],
      remote_identifier: params[:serverId],
      provider_public_key_base64: params[:publicKey]
    )

    render json: registration_confirmation
  end

  private

  def registration_confirmation
    {
      faspId: current_provider.id.to_s,
      publicKey: current_provider.server_public_key_base64,
      registrationCompletionUri: new_admin_fasp_provider_registration_url(current_provider),
    }
  end
end
