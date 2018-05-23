#!/usr/bin/env ruby -wKU

require "benchmark"
require "thread_safe"

hash  = {}
cache = ThreadSafe::Cache.new

ENTRIES = 10_000

ENTRIES.times do |i|
  hash[i]  = i
  cache[i] = i
end

TESTS = 40_000_000
Benchmark.bmbm do |results|
  key = rand(10_000)

  results.report('Hash#[]') do
    TESTS.times { hash[key] }
  end

  results.report('Cache#[]') do
    TESTS.times { cache[key] }
  end

  results.report('Hash#each_pair') do
    (TESTS / ENTRIES).times { hash.each_pair {|k,v| v} }
  end

  results.report('Cache#each_pair') do
    (TESTS / ENTRIES).times { cache.each_pair {|k,v| v} }
  end
end
