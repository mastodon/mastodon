# frozen_string_literal: true

# Monkey patching until https://github.com/httprb/http/pull/757 is merged
unless HTTP::Request::METHODS.include?(:purge)
  module HTTP
    class Request
      METHODS = METHODS.dup.push(:purge).freeze
    end
  end
end
