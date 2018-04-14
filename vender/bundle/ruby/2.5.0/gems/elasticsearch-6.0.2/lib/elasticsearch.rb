require "elasticsearch/version"

require 'elasticsearch/transport'
require 'elasticsearch/api'

module Elasticsearch
  module Transport
    class Client
      include Elasticsearch::API
    end
  end
end
