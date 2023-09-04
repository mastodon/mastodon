# frozen_string_literal: true

module AuthorizedFetchHelper
  def authorized_fetch_mode?
    ENV.fetch('AUTHORIZED_FETCH') { Setting.authorized_fetch } == 'true' || Rails.configuration.x.limited_federation_mode
  end

  def authorized_fetch_overridden?
    ENV.key?('AUTHORIZED_FETCH') || Rails.configuration.x.limited_federation_mode
  end
end
