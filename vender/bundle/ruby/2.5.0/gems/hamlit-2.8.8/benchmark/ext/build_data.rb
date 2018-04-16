#!/usr/bin/env ruby

require 'bundler/setup'
require 'hamlit'
require 'faml'
require 'benchmark/ips'
require_relative '../utils/benchmark_ips_extension'

h = { 'user' => { id: 1234, name: 'k0kubun' }, book_id: 5432 }

Benchmark.ips do |x|
  quote = "'"
  faml_options = { data: h }
  x.report("Faml::AB.build")    { Faml::AttributeBuilder.build(quote, true, nil, faml_options) }
  x.report("Hamlit.build_data") { Hamlit::AttributeBuilder.build_data(true, quote, h) }
  x.compare!
end
