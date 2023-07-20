# frozen_string_literal: true

class InteractionProxyController < ApplicationController
  include Authorization

  skip_forgery_protection

  before_action :check_params!
  before_action :store_location!
  before_action :authenticate_user!
  before_action :set_resource

  def create
    if @resource.is_a?(Account)
      redirect_to web_url("@#{@resource.pretty_acct}")
    elsif @resource.is_a?(Status)
      redirect_to web_url("@#{@resource.account.pretty_acct}/#{@resource.id}")
    else
      not_found
    end
  end

  private

  def store_location!
    # This is a bit of a hack to ensure the user goes back to the interaction after logging in
    store_location_for(:user, authorize_interaction_url({ uri: uri_param })) unless user_signed_in?
  end

  def set_resource
    @resource = ResolveURLService.new.call(uri_param)
    authorize(@resource, :show?) if @resource.is_a?(Status)
  rescue Mastodon::NotPermittedError
    not_found
  end

  def check_params!
    unprocessable_entity unless parsed_uri.path && %w(http https).include?(parsed_uri.scheme)
  end

  def parsed_uri
    Addressable::URI.parse(uri_param).normalize
  end

  def uri_param
    params.require(:id)
  end
end
