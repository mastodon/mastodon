# frozen_string_literal: true

module RoutingHelper
  extend ActiveSupport::Concern

  include ActionView::Helpers::AssetTagHelper
  include ViteRails::TagHelpers

  included do
    include Rails.application.routes.url_helpers

    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end

  def full_asset_url(source, **)
    source = ActionController::Base.helpers.asset_url(source, **) unless use_storage?

    URI.join(asset_host, source).to_s
  end

  def expiring_asset_url(attachment, expires_in)
    case Paperclip::Attachment.default_options[:storage]
    when :s3, :azure
      attachment.expiring_url(expires_in.to_i)
    when :fog
      if Paperclip::Attachment.default_options.dig(:fog_credentials, :openstack_temp_url_key).present?
        attachment.expiring_url(expires_in.from_now)
      else
        full_asset_url(attachment.url)
      end
    when :filesystem
      full_asset_url(attachment.url)
    end
  end

  def asset_host
    Rails.configuration.action_controller.asset_host || root_url
  end

  def frontend_asset_path(source, **)
    vite_asset_path(source, **)
  end

  def frontend_asset_url(source, **)
    full_asset_url(frontend_asset_path(source, **))
  end

  def use_storage?
    Rails.configuration.x.use_s3 || Rails.configuration.x.use_swift
  end
end
