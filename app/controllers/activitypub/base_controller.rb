# frozen_string_literal: true

class ActivityPub::BaseController < Api::BaseController
  skip_before_action :require_authenticated_user!
  skip_before_action :require_not_suspended!
  skip_around_action :set_locale

  private

  def set_cache_headers
    response.headers['Vary'] = 'Signature' if authorized_fetch_mode?
  end

  def skip_temporary_suspension_response?
    false
  end
end
