# frozen_string_literal: true

Regexp.timeout = ENV['REGEXP_TIMEOUT'].to_f if Regexp.respond_to?(:timeout=) && ENV['REGEXP_TIMEOUT']
