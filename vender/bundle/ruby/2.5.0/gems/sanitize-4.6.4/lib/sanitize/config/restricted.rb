# encoding: utf-8

class Sanitize
  module Config
    RESTRICTED = freeze_config(
      :elements => %w[b em i strong u]
    )
  end
end
