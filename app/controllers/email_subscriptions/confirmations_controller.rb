# frozen_string_literal: true

class EmailSubscriptions::ConfirmationsController < ApplicationController
  layout 'auth'

  before_action :set_email_subscription

  def show
    @email_subscription.confirm! unless @email_subscription.confirmed?
  end

  private

  def set_email_subscription
    @email_subscription = EmailSubscription.find_by!(confirmation_token: params[:confirmation_token])
  end
end
