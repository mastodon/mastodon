# frozen_string_literal: true

if Rails.configuration.x.use_vips
  ENV['VIPS_BLOCK_UNTRUSTED'] = 'true'

  require 'vips'

  abort('Incompatible libvips version, please install libvips >= 8.13') unless Vips.at_least_libvips?(8, 13)

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
