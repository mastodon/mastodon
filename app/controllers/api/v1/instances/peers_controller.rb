# frozen_string_literal: true

class Api::V1::Instances::PeersController < Api::BaseController
  respond_to :json

  def index
    render_cached_json('api:v1:instances:peers:index', expires_in: 1.day) { Account.remote.domains }
  end
end
