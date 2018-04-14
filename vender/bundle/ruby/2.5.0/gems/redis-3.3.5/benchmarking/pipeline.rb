require "benchmark"

$:.push File.join(File.dirname(__FILE__), 'lib')

require 'redis'

ITERATIONS = 10000

@r = Redis.new

Benchmark.bmbm do |benchmark|
  benchmark.report("set") do
    @r.flushdb

    ITERATIONS.times do |i|
      @r.set("foo#{i}", "Hello world!")
      @r.get("foo#{i}")
    end
  end

  benchmark.report("set (pipelined)") do
    @r.flushdb

    @r.pipelined do
      ITERATIONS.times do |i|
        @r.set("foo#{i}", "Hello world!")
        @r.get("foo#{i}")
      end
    end
  end

  benchmark.report("lpush+ltrim") do
    @r.flushdb

    ITERATIONS.times do |i|
      @r.lpush "lpush#{i}", i
      @r.ltrim "ltrim#{i}", 0, 30
    end
  end

  benchmark.report("lpush+ltrim (pipelined)") do
    @r.flushdb

    @r.pipelined do
      ITERATIONS.times do |i|
        @r.lpush "lpush#{i}", i
        @r.ltrim "ltrim#{i}", 0, 30
      end
    end
  end
end
