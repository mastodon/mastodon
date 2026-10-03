# frozen_string_literal: true

class Settings::RelayPreferencesController < Settings::BaseController
  before_action :set_account
  before_action :set_relays

  def show
    @batch = Form::RelayPreferencesBatch.new(relay_ids: RelayPreference.where(account: @account, enabled: true).pluck(:relay_id), current_account: @account)
  end

  def update
    @batch = Form::RelayPreferencesBatch.new(resource_params.merge(current_account: @account))
    @batch.save
  ensure
    redirect_to settings_relay_preferences_path
  end

  private

  def set_account
    @account = current_account
  end

  def set_relays
    @relays = Relay.enabled.where(requires_opt_in: true).includes(:account)
  end

  def resource_params
    params.expect(form_relay_preferences_batch: [relay_ids: []])
  end
end
