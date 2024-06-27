# frozen_string_literal: true

if Rails.configuration.x.use_vips
  ENV['VIPS_BLOCK_UNTRUSTED'] = 'true'

  require 'vips'

  unless Vips.at_least_libvips?(8, 13)
    abort <<~ERROR.squish
      Incompatible libvips version (#{Vips.version_string}), please install libvips >= 8.13
    ERROR
  end

  Vips.block('VipsForeign', true)

  %w(
    VipsForeignLoadNsgif
    VipsForeignLoadJpeg
    VipsForeignLoadPng
    VipsForeignLoadWebp
    VipsForeignLoadHeif
    VipsForeignSavePng
    VipsForeignSaveSpng
    VipsForeignSaveJpeg
    VipsForeignSaveWebp
  ).each do |operation|
    Vips.block(operation, false)
  end

  Vips.block_untrusted(true)
end
