# frozen_string_literal: true

# 0.5s is a fairly high timeout, but that should account for slow servers under load
Regexp.timeout = 0.5 if Regexp.respond_to?(:timeout=)
