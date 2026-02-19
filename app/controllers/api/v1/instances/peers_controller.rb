# frozen_string_literal: true

class Api::V1::Instances::PeersController < Api::V1::Instances::BaseController
  before_action :require_enabled_api!

  skip_around_action :set_locale

  # Override `current_user` to avoid reading session cookies unless in limited federation mode
  def current_user
    super if limited_federation_mode?
  end

  def index
    cache_even_if_authenticated!
    render_with_cache(expires_in: 1.day) { Instance.searchable.pluck(:domain) }
  end

  private

  def require_enabled_api!
    head 404 unless Setting.peers_api_enabled && !limited_federation_mode?
  end
end
