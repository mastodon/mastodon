# frozen_string_literal: true

class RedirectsController < ApplicationController
  vary_by 'Accept-Language'

  before_action :set_redirect_path
  before_action :set_app_body_class

  def show
    render 'redirects/show', layout: 'application'
  end

  private

  def set_app_body_class
    @body_classes = 'app-body'
  end

  def set_redirect_path
    salt = Rails.application.key_generator.generate_key('redirect-url')
    digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), salt, params[:url])
    return not_found if digest != params[:digest]

    @redirect_path = params[:url]
  end
end
