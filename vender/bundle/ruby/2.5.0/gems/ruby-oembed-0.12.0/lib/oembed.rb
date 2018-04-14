$:.unshift File.dirname(__FILE__)

require 'net/http'

require 'oembed/version'
require 'oembed/errors'
require 'oembed/formatter'
require 'oembed/provider'
require 'oembed/provider_discovery'
require 'oembed/providers'
require 'oembed/response'
require 'oembed/response/photo'
require 'oembed/response/video'
require 'oembed/response/link'
require 'oembed/response/rich'
