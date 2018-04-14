#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), 'json_gem')

require 'json_common_interface_test'
require 'json_encoding_test'
require 'json_ext_parser_test'
require 'json_fixtures_test'
require 'json_generator_test'
require 'json_generic_object_test'
require 'json_parser_test'
require 'json_string_matching_test'
