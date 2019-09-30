# frozen_string_literal: true

class Auth::ChallengesController < ApplicationController
  include ChallengableConcern

  layout 'auth'

  before_action :set_pack
  before_action :authenticate_user!

  skip_before_action :require_functional!

  def create
    if challenge_passed?
      session[:challenge_passed_at] = Time.now.utc
      redirect_to challenge_params[:return_to]
    else
      @challenge = Form::Challenge.new(return_to: challenge_params[:return_to])
      flash.now[:alert] = I18n.t('challenge.invalid_password')
      render_challenge
    end
  end

  private

  def set_pack
    use_pack 'auth'
  end
end
