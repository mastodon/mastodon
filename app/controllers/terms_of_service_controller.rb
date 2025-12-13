# frozen_string_literal: true

class TermsOfServiceController < ApplicationController
  include WebAppControllerConcern

  skip_before_action :require_functional!
  skip_before_action :redirect_to_tos_interstitial!

  before_action :clear_redirect_interstitial!

  def show
    expires_in(15.seconds, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.day) unless user_signed_in?
  end

  private

  def clear_redirect_interstitial!
    return unless user_signed_in?

    current_user.update(require_tos_interstitial: false)
  end
end
