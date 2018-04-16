# encoding: UTF-8
$KCODE = 'u' unless "1.9".respond_to?(:encoding)

require File.expand_path("../performance", __FILE__)
require "benchmark"

job = HTMLEntitiesJob.new
job.all(100) # Warm up to give JRuby a fair shake.

Benchmark.benchmark do |b|
  b.report("Encoding"){ job.encode(100) }
  b.report("Decoding"){ job.decode(100) }
end
