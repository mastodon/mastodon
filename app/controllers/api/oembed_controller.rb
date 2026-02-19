# frozen_string_literal: true

class Api::OEmbedController < Api::BaseController
  skip_before_action :require_authenticated_user!

  before_action :set_status
  before_action :require_public_status!

  def show
    render json: @status, serializer: OEmbedSerializer, width: params[:maxwidth], height: params[:maxheight]
  end

  private

  def set_status
    @status = status_finder.status
  end

  def require_public_status!
    not_found if @status.hidden?
  end

  def status_finder
    StatusFinder.new(params[:url])
  end
end
