# frozen_string_literal: true

# This concern is inspired by "sudo mode" on GitHub. It
# is a way to re-authenticate a user before allowing them
# to see or perform an action.
#
# Add `before_action :require_challenge!` to actions you
# want to protect.
#
# The user will be shown a page to enter the challenge (which
# is either the password, or just the username when no
# password exists). Upon passing, there is a grace period
# during which no challenge will be asked from the user.
#
# Accessing challenge-protected resources during the grace
# period will refresh the grace period.
module ChallengableConcern
  extend ActiveSupport::Concern

  CHALLENGE_TIMEOUT = 1.hour.freeze

  def require_challenge!
    return if skip_challenge?

    if challenge_passed_recently?
      session[:challenge_passed_at] = Time.now.utc
      return
    end

    @challenge = Form::Challenge.new(return_to: request.url)

    if params.key?(:form_challenge)
      if challenge_passed?
        session[:challenge_passed_at] = Time.now.utc
      else
        flash.now[:alert] = I18n.t('challenge.invalid_password')
        render_challenge
      end
    else
      render_challenge
    end
  end

  def render_challenge
    render 'auth/challenges/new', layout: 'auth'
  end

  def challenge_passed?
    current_user.valid_password?(challenge_params[:current_password])
  end

  def skip_challenge?
    current_user.encrypted_password.blank?
  end

  def challenge_passed_recently?
    session[:challenge_passed_at].present? && session[:challenge_passed_at] >= CHALLENGE_TIMEOUT.ago
  end

  def challenge_params
    params.require(:form_challenge).permit(:current_password, :return_to)
  end
end
