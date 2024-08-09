# frozen_string_literal: true

class Api::V2::ResolvedUrlsController < Api::BaseController
  include Authorization

  before_action :set_url
  before_action :set_resource

  def show
    expires_in(1.day, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.day) unless user_signed_in?

    case @resource
    when Account
      render json: { 'resolvedPath' => "/@#{@resource.pretty_acct}" }
    when Status
      render json: { 'resolvedPath' => "/@#{@resource.account.pretty_acct}/#{@resource.id}" }
    else
      render json: {}
    end
  end

  private

  def set_url
    @url = params.require(:url)
  end

  def set_resource
    @resource = ResolveURLService.new.call(@url, on_behalf_of: current_user, allow_caching: true) if user_signed_in?
  end
end
