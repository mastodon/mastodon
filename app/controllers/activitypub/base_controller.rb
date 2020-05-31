# frozen_string_literal: true

class ActivityPub::BaseController < Api::BaseController
  skip_before_action :require_authenticated_user!

  private

  def set_cache_headers
    response.headers['Vary'] = 'Signature' if authorized_fetch_mode?
  end
end
