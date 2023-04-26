# frozen_string_literal: true

class Api::V1::Instances::PeersController < Api::BaseController
  before_action :require_enabled_api!

  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?
  skip_around_action :set_locale

  vary_by ''

  # Override `current_user` to avoid reading session cookies unless in whitelist mode
  def current_user
    super if whitelist_mode?
  end

  def index
    cache_even_if_authenticated!
    render_with_cache(expires_in: 1.day) { Instance.where.not(domain: DomainBlock.select(:domain)).pluck(:domain) }
  end

  private

  def require_enabled_api!
    head 404 unless Setting.peers_api_enabled && !whitelist_mode?
  end
end
