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
    preload_link_tag(src, options.merge(integrity: integrity))
  end
end

Webpacker::Helper.prepend(Webpacker::HelperExtensions)
