require 'base64'
require 'openssl'
require 'http'
require 'addressable'
require 'nokogiri'

require 'ostatus2/version'
require 'ostatus2/publication'
require 'ostatus2/subscription'
require 'ostatus2/magic_key'
require 'ostatus2/salmon'

module OStatus2
  class Error < StandardError
  end

  class BadSalmonError < Error
  end
end
