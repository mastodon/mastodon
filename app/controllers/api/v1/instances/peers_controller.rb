# frozen_string_literal: true

class Api::V1::Instances::PeersController < Api::BaseController
  before_action :require_enabled_api!

  respond_to :json

  def index
    render_cached_json('api:v1:instances:peers:index', expires_in: 1.day) { Account.remote.domains }
  end

  private

  def require_enabled_api!
    head 404 unless Setting.peers_api_enabled
  end
end
