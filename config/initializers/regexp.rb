# frozen_string_literal: true

# 2s is a fairly high default, but that should account for slow servers under load
Regexp.timeout = ENV.fetch('REGEXP_TIMEOUT', 2).to_f if Regexp.respond_to?(:timeout=)
