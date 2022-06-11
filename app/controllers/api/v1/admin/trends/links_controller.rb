# frozen_string_literal: true

class Api::V1::Admin::Trends::LinksController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :'admin:read' }
  before_action :set_links

  after_action :verify_authorized

  def index
    authorize :dashboard, :index?
    render json: @links, each_serializer: REST::Trends::LinkSerializer
  end

  private

  def set_links
    @links = Trends.links.query.limit(limit_param(10))
  end
end
