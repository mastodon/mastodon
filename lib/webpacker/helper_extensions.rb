# frozen_string_literal: true

module Webpacker::HelperExtensions
  def javascript_pack_tag(name, **options)
    src, integrity = current_webpacker_instance.manifest.lookup!(name, type: :javascript, with_integrity: true)
    javascript_include_tag(src, options.merge(integrity: integrity))
  end

  def stylesheet_pack_tag(name, **options)
    src, integrity = current_webpacker_instance.manifest.lookup!(name, type: :stylesheet, with_integrity: true)
    stylesheet_link_tag(src, options.merge(integrity: integrity))
  end

  def preload_pack_asset(name, **options)
    src, integrity = current_webpacker_instance.manifest.lookup!(name, with_integrity: true)

    # This attribute will only work if the assets are on a different domain.
    # And Webpack will (correctly) only add it in this case, so we need to conditionally set it here
    # otherwise the preloaded request and the real request will have different crossorigin values
    # and the preloaded file wont be loaded
    crossorigin = 'anonymous' if Rails.configuration.action_controller.asset_host.present?

    preload_link_tag(src, options.merge(integrity: integrity, crossorigin: crossorigin))
  end
end

Webpacker::Helper.prepend(Webpacker::HelperExtensions)
