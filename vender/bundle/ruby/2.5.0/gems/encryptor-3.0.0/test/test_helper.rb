require 'simplecov'
require 'simplecov-rcov'
require "codeclimate-test-reporter"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter,
  CodeClimate::TestReporter::Formatter
]

SimpleCov.start do
  add_filter 'test'
end

CodeClimate::TestReporter.start

require 'minitest/autorun'
require 'minitest/unit'
require 'digest/sha2'

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))
require 'encryptor'
require 'openssl_helper'

require 'encryptor/string'
class StringWithEncryptor < String
  include Encryptor::String
end
