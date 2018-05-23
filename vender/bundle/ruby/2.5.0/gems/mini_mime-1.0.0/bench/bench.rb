require 'memory_profiler'
require 'benchmark/ips'

$: << File.expand_path('../../lib', __FILE__)


puts
puts "Memory stats for requiring mime/types/columnar"
result = MemoryProfiler.report do
  require 'mime/types/columnar'
end

puts "Total allocated: #{result.total_allocated_memsize} bytes (#{result.total_allocated} objects)"
puts "Total retained:  #{result.total_retained_memsize} bytes (#{result.total_retained} objects)"

puts
puts "Memory stats for requiring mini_mime"
result = MemoryProfiler.report do
  require 'mini_mime'
end

puts "Total allocated: #{result.total_allocated_memsize} bytes (#{result.total_allocated} objects)"
puts "Total retained:  #{result.total_retained_memsize} bytes (#{result.total_retained} objects)"


Benchmark.ips do |bm|
  bm.report 'cached content_type lookup MiniMime' do
    MiniMime.lookup_by_filename("a.txt").content_type
  end

  bm.report 'content_type lookup Mime::Types' do
    MIME::Types.type_for("a.txt")[0].content_type
  end
end

module MiniMime
  class Db
    class RandomAccessDb
      alias_method :lookup, :lookup_uncached
    end
  end
end

Benchmark.ips do |bm|
  bm.report 'uncached content_type lookup MiniMime' do
    MiniMime.lookup_by_filename("a.txt").content_type
  end

  bm.report 'content_type lookup Mime::Types' do
    MIME::Types.type_for("a.txt")[0].content_type
  end
end
