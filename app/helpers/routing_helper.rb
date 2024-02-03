# frozen_string_literal: true

module RoutingHelper
  extend ActiveSupport::Concern

  include ActionView::Helpers::AssetTagHelper
  include Webpacker::Helper

  included do
    include Rails.application.routes.url_helpers

    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end

  def full_asset_url(source, **options)
    source = ActionController::Base.helpers.asset_url(source, **options) unless use_storage?

    URI.join(asset_host, source).to_s
  end

  def asset_host
    Rails.configuration.action_controller.asset_host || root_url
  end

  def frontend_asset_path(source, **options)
    asset_pack_path("media/#{source}", **options)
  end

  def frontend_asset_url(source, **options)
    full_asset_url(frontend_asset_path(source, **options))
  end

  def use_storage?
    Rails.configuration.x.use_s3 || Rails.configuration.x.use_swift
  end
end
