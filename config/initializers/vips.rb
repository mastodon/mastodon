# frozen_string_literal: true

Vips.block_untrusted(true) if Vips.at_least_libvips?(8, 13)
