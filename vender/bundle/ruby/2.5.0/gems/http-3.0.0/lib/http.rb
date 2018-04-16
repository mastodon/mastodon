# frozen_string_literal: true

require "http/parser"

require "http/errors"
require "http/timeout/null"
require "http/timeout/per_operation"
require "http/timeout/global"
require "http/chainable"
require "http/client"
require "http/connection"
require "http/options"
require "http/request"
require "http/request/writer"
require "http/response"
require "http/response/body"
require "http/response/parser"

# HTTP should be easy
module HTTP
  extend Chainable

  class << self
    # HTTP[:accept => 'text/html'].get(...)
    alias [] headers
  end
end
