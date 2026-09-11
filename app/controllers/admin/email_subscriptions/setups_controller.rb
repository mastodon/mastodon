# frozen_string_literal: true

class Admin::EmailSubscriptions::SetupsController < Admin::BaseController
  before_action :require_enabled!

  def show
    authorize :email_subscription, :enable?

    @form = Form::EmailSubscriptionsConfirmation.new
  end

  def create
    authorize :email_subscription, :enable?

    @form = Form::EmailSubscriptionsConfirmation.new(resource_params)

    if @form.valid?
      Setting.email_subscriptions = true
      redirect_to admin_email_subscriptions_path
    else
      render :show
    end
  end

  private

  def require_enabled!
    raise ActionController::RoutingError, 'Feature disabled' unless Rails.application.config.x.email_subscriptions
  end

  def resource_params
    params.expect(form_email_subscriptions_confirmation: [:agreement_email_volume, :agreement_privacy_and_terms])
  end
end
