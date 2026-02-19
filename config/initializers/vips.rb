# frozen_string_literal: true

ENV['VIPS_BLOCK_UNTRUSTED'] = 'true'

require 'vips'

unless Vips.at_least_libvips?(8, 13)
  abort <<~ERROR.squish # rubocop:disable Rails/Exit
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

# In some places of the code, we rescue this exception, but we don't always
# load libvips, so it may be an undefined constant:
unless defined?(Vips)
  module Vips
    class Error < StandardError; end
  end
end
