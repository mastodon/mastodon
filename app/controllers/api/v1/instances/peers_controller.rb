# frozen_string_literal: true

class Api::V1::Instances::PeersController < Api::BaseController
  before_action :require_enabled_api!

  skip_before_action :set_cache_headers
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  def index
    expires_in 1.day, public: true
    render_with_cache(expires_in: 1.day) { Instance.where.not(domain: DomainBlock.select(:domain)).pluck(:domain) }
  end

  private

  def require_enabled_api!
    head 404 unless Setting.peers_api_enabled && !whitelist_mode?
  end
end
