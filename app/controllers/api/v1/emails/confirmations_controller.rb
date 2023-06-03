# frozen_string_literal: true

class Api::V1::Emails::ConfirmationsController < Api::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:accounts' }, only: :check
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, except: :check
  before_action :require_user_owned_by_application!, except: :check
  before_action :require_user_not_confirmed!, except: :check

  def create
    current_user.update!(email: params[:email]) if params.key?(:email)
    current_user.resend_confirmation_instructions

    render_empty
  end

  def check
    render json: current_user.confirmed?
  end

  private

  def require_user_owned_by_application!
    render json: { error: 'This method is only available to the application the user originally signed-up with' }, status: 403 unless current_user && current_user.created_by_application_id == doorkeeper_token.application_id
  end

  def require_user_not_confirmed!
    render json: { error: 'This method is only available while the e-mail is awaiting confirmation' }, status: 403 unless !current_user.confirmed? || current_user.unconfirmed_email.present?
  end
end
