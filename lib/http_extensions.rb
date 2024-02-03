# frozen_string_literal: true

# Monkey patching until https://github.com/httprb/http/pull/757 is merged
unless HTTP::Request::METHODS.include?(:purge)
  methods = HTTP::Request::METHODS.dup
  HTTP::Request.send(:remove_const, :METHODS)
  HTTP::Request.const_set(:METHODS, methods.push(:purge).freeze)
end
