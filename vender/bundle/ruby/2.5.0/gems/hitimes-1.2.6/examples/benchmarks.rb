require 'benchmark'
require 'time'

#
# this is all here in case this example is run from the examples directory
#
begin
  require 'hitimes'
rescue LoadError => le
  ext_path = File.expand_path( File.join( File.dirname( __FILE__ ), "..", "ext" ) )
  lib_path = File.expand_path( File.join( File.dirname( __FILE__ ), "..", "lib" ) )
  if $:.include?( ext_path ) then
    raise le
  end
  $: << ext_path
  $: << lib_path
  retry
end

#----------------------------------------------------------------------
# test program to look at the performance sampling time durations using
# different methods
#----------------------------------------------------------------------

include Benchmark

#
# Normal apprach to Interval usage
#
def hitimes_duration_i1
  i = Hitimes::Interval.new
  i.start
  i.stop
end

#
# Use the easy access method to start stop an interval
#
def hitimes_duration_i2
  Hitimes::Interval.now.stop
end

#
# Use a new timer each time
#
def hitimes_duration_t1
  Hitimes::TimedMetric.now('duration_t1').stop
end

#
# reuse the same timer over and over
#
HT2= Hitimes::TimedMetric.new( 'duration_t2' )
def hitimes_duration_t2
  HT2.start
  HT2.stop
end

HT3 = Hitimes::TimedMetric.new( 'duration_t3' )
def hitimes_duration_t3
  HT3.measure { nil }
end

#
# Check out the speed of the TimedValueMetric too
#
def hitimes_duration_tv1
  Hitimes::TimedValueMetric.now( 'duration_tv1' ).stop( 42 )
end

HTV2 = Hitimes::TimedValueMetric.new( 'duration_tv2' )
def hitimes_duration_tv2
  HTV2.start
  HTV2.stop( 42 )
end

HTV3 = Hitimes::TimedValueMetric.new( 'duration_tv3' )
def hitimes_duration_tv3
  HTV3.measure( 42 ) { nil }
end

#
# use the Struct::Tms values and return  the difference in User time between 2 
# successive calls
#
def process_duration
  t1 = Process.times.utime
  Process.times.utime - t1
end

#
# Take 2 times and subtract one from the other
#
def time_duration
  t1 = Time.now.to_f
  Time.now.to_f - t1
end
  

puts "Testing time sampling 100,000 times"

bm(30) do |x|
  x.report("Process")                     { 100_000.times { process_duration } }
  x.report("Time")                        { 100_000.times { time_duration    } }
  x.report("Hitimes::TimedMetric 1")      { 100_000.times { hitimes_duration_t1 } }
  x.report("Hitimes::TimedMetric 2")      { 100_000.times { hitimes_duration_t2 } }
  x.report("Hitimes::TimedMetric 3")      { 100_000.times { hitimes_duration_t3 } }
  x.report("Hitimes::Interval 1")         { 100_000.times { hitimes_duration_i1 } }
  x.report("Hitimes::Interval 2")         { 100_000.times { hitimes_duration_i2 } }
  x.report("Hitimes::TimedValueMetric 1") { 100_000.times { hitimes_duration_tv1 } }
  x.report("Hitimes::TimedValueMetric 2") { 100_000.times { hitimes_duration_tv2 } }
  x.report("Hitimes::TimedValueMetric 3") { 100_000.times { hitimes_duration_tv3 } }
end
