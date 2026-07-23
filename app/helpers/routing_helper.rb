# frozen_string_literal: true

module RoutingHelper
  extend ActiveSupport::Concern

  include ActionView::Helpers::AssetTagHelper

  # include ViteRails::TagHelpers

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

  # Temporary vite helper stubs
  # TODO: Move to their own helper
  # TODO: Integrity

  VITE_URL = 'http://localhost:3036/packs-dev'

  def vite_javascript_tag(*names, type: 'module', crossorigin: '', **)
    scripts = names.map do |name|
      # If the name is single file we assume it is inside app/javascripts/entrypoints
      name.include?('/') ? "#{VITE_URL}/#{name}" : "#{VITE_URL}/entrypoints/#{name}"
    end

    javascript_include_tag(*scripts, crossorigin: crossorigin, type: type, extname: false, **)
  end

  def vite_typescript_tag(*names, **)
    vite_javascript_tag(*names, asset_type: :typescript, **)
  end

  def vite_stylesheet_tag(*names, **options)
    style_paths = names.map do |name|
      # If the name is single file we assume it is inside app/javascripts/entrypoints
      name.include?('/') ? "#{VITE_URL}/#{name}" : "#{VITE_URL}/entrypoints/#{name}"
    end

    options[:extname] = false if Rails::VERSION::MAJOR >= 7

    stylesheet_link_tag(*style_paths, **options)
  end

  def vite_client_tag(crossorigin: 'anonymous', **)
    src = "#{VITE_URL}/@vite/client"
    javascript_include_tag(src, type: 'module', extname: false, crossorigin: crossorigin, **)
  end

  def vite_react_refresh_tag(**options)
    options[:nonce] = true if Rails::VERSION::MAJOR >= 6 && !options.key?(:nonce)

    preamble = <<~REACT_PREAMBLE_CODE
      import RefreshRuntime from '#{VITE_URL}/@react-refresh'
      RefreshRuntime.injectIntoGlobalHook(window)
      window.$RefreshReg$ = () => {}
      window.$RefreshSig$ = () => (type) => type
      window.__vite_plugin_react_preamble_installed__ = true
    REACT_PREAMBLE_CODE

    javascript_tag(preamble.html_safe, type: :module, **options) # rubocop:disable Rails/OutputSafety
  end

  def vite_asset_path(name, **_options)
    asset = name.include?('/') ? "#{VITE_URL}/#{name}" : "#{VITE_URL}/entrypoints/#{name}"
    path_to_asset asset
  end

  def vite_polyfills_tag
    ''
  end

  def vite_preload_file_tag(*)
    ''
  end
end
