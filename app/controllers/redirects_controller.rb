# frozen_string_literal: true

class RedirectsController < ApplicationController
  before_action :set_url
  before_action :set_resource

  def show
    expires_in(1.day, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.day) unless user_signed_in?

    case @resource
    when Account
      redirect_to web_url("@#{@resource.pretty_acct}")
    when Status
      redirect_to web_url("@#{@resource.account.pretty_acct}/#{@resource.id}")
    else
      redirect_to @url, allow_other_host: true
    end
  end

  private

  def set_url
    @url = params.require(:url)
  end

  def set_resource
    @resource = ResolveURLService.new.call(@url) if user_signed_in?
  end
end
