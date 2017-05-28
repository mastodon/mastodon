# frozen_string_literal: true

module StyleHelper
  def stylesheet_for_layout
    if asset_exist? 'custom.css'
      'custom'
    else
      'application'
    end
  end

  def asset_exist?(path)
    true if Webpacker::Manifest.lookup(path)
  rescue Webpacker::FileLoader::NotFoundError
    false
  end
end
