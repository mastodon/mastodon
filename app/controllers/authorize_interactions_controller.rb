# frozen_string_literal: true

class AuthorizeInteractionsController < ApplicationController
  include Authorization

  layout 'modal'

  before_action :authenticate_user!
  before_action :set_body_classes
  before_action :set_resource

  def show
    if @resource.is_a?(Account)
      render :show
    elsif @resource.is_a?(Status)
      redirect_to web_url("@#{@resource.account.pretty_acct}/#{@resource.id}")
    else
      render :error
    end
  end

  def create
    if @resource.is_a?(Account) && FollowService.new.call(current_account, @resource, with_rate_limit: true)
      render :success
    else
      render :error
    end
  rescue ActiveRecord::RecordNotFound
    render :error
  end

  private

  def set_resource
    @resource = located_resource
    authorize(@resource, :show?) if @resource.is_a?(Status)
  rescue Mastodon::NotPermittedError
    not_found
  end

  def located_resource
    if uri_param_is_url?
      ResolveURLService.new.call(uri_param)
    else
      account_from_remote_follow
    end
  end

  def account_from_remote_follow
    ResolveAccountService.new.call(uri_param)
  end

  def uri_param_is_url?
    parsed_uri.path && %w(http https).include?(parsed_uri.scheme)
  end

  def parsed_uri
    Addressable::URI.parse(uri_param).normalize
  end

  def uri_param
    params[:uri] || params.fetch(:acct, '').gsub(/\Aacct:/, '')
  end

  def set_body_classes
    @body_classes = 'modal-layout'
  end
end
