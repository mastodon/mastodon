require 'spec_helper'

describe Hitimes::TimedValueMetric do
  before( :each ) do
    @tm = Hitimes::TimedValueMetric.new( 'test-timed-value-metric' )
  end

  it "knows if it is running or not" do
    @tm.running?.must_equal false
    @tm.start
    @tm.running?.must_equal true
    @tm.stop( 1 )
    @tm.running?.must_equal false
  end

  it "#split returns the last duration and the timer is still running" do
    @tm.start
    d = @tm.split( 1 )
    @tm.running?.must_equal true
    d.must_be :>, 0
    @tm.value_stats.count.must_equal 1
    @tm.timed_stats.count.must_equal 1
    @tm.duration.must_equal d
  end

  it "#stop returns false if called more than once in a row" do
    @tm.start
    @tm.stop( 1 ).must_be :>, 0
    @tm.stop( 1 ).must_equal false
  end

  it "does not count a currently running interval as an interval in calculations" do
    @tm.start
    @tm.value_stats.count.must_equal 0
    @tm.timed_stats.count.must_equal 0
    @tm.split( 1 )
    @tm.value_stats.count.must_equal 1
    @tm.timed_stats.count.must_equal 1
  end

  it "#split called on a stopped timer does nothing" do
    @tm.start
    @tm.stop( 1 )
    @tm.split( 1 ).must_equal false
  end

  it "calculates the mean of the durations" do
    3.times { |x| @tm.start ; sleep 0.05 ; @tm.stop(x) }
    @tm.timed_stats.mean.must_be_close_to(0.05, 0.01)
    @tm.value_stats.mean.must_equal 1.00
  end

  it "calculates the rate of the counts " do
    5.times { |x| @tm.start ; sleep 0.05 ; @tm.stop( x ) }
    @tm.rate.must_be_close_to(40.0, 1.0)
  end


  it "calculates the stddev of the durations" do
    3.times { |x| @tm.start ; sleep(0.05 * x) ; @tm.stop(x) }
    @tm.timed_stats.stddev.must_be_close_to(0.05, 0.001)
    @tm.value_stats.stddev.must_equal 1.0
  end

  it "returns 0.0 for stddev if there is no data" do
    @tm.timed_stats.stddev.must_equal 0.0
    @tm.value_stats.stddev.must_equal 0.0
  end

  it "keeps track of the min value" do
    3.times { |x| @tm.start ; sleep 0.05 ; @tm.stop( x ) }
    @tm.timed_stats.min.must_be_close_to( 0.05, 0.003 )
    @tm.value_stats.min.must_equal 0
  end

  it "keeps track of the max value" do
    3.times { |x| @tm.start ; sleep 0.05 ; @tm.stop( x ) }
    @tm.timed_stats.max.must_be_close_to( 0.05, 0.003 )
    @tm.value_stats.max.must_equal 2
  end

  it "keeps track of the sum value" do
    3.times { |x| @tm.start ; sleep 0.05 ; @tm.stop( x ) }
    @tm.timed_stats.sum.must_be_close_to( 0.15, 0.01 )
    @tm.value_stats.sum.must_equal 3
  end
  
  it "keeps track of the sum of squares value" do
    3.times { |x| @tm.start ; sleep 0.05 ; @tm.stop( x ) }
    @tm.timed_stats.sumsq.must_be_close_to(0.0075, 0.0005)
    @tm.value_stats.sumsq.must_equal 5
  end

  it "keeps track of the minimum start time of all the intervals" do
    f1 = Time.now.gmtime.to_f * 1000000
    5.times { @tm.start ; sleep 0.05 ; @tm.stop( 1 ) }
    f2 = Time.now.gmtime.to_f * 1000000
    @tm.sampling_start_time.must_be :>=, f1
    @tm.sampling_start_time.must_be :<, f2
    # distance from now to start time should be greater than the distance from
    # the start to the min start_time
    (f2 - @tm.sampling_start_time).must_be :>, ( @tm.sampling_start_time - f1 )
  end

  it "keeps track of the last stop time of all the intervals" do
    f1 = Time.now.gmtime.to_f * 1_000_000
    5.times { @tm.start ; sleep 0.05 ; @tm.stop( 1 ) }
    sleep 0.05
    f2 = Time.now.gmtime.to_f * 1_000_000
    @tm.sampling_stop_time.must_be :>, f1
    @tm.sampling_stop_time.must_be :<=, f2
    # distance from now to max stop time time should be less than the distance
    # from the start to the max stop time
    (f2 - @tm.sampling_stop_time).must_be :<, ( @tm.sampling_stop_time - f1 )
  end

  it "can create an already running timer" do
    t = Hitimes::TimedValueMetric.now( 'already-running' )
    t.running?.must_equal true
  end

  it "can measure a block of code from an instance" do
    t = Hitimes::TimedValueMetric.new( 'measure a block' )
    3.times { t.measure( 1 ) { sleep 0.05 } }
    t.duration.must_be_close_to(0.15, 0.004)
    t.timed_stats.count.must_equal 3
    t.value_stats.count.must_equal 3
  end

  it "returns the value of the block when measuring" do
    t = Hitimes::TimedValueMetric.new( 'measure a block' )
    x = t.measure( 42 ) { sleep 0.05; 42 }
    t.duration.must_be_close_to(0.05, 0.002)
    x.must_equal 42
  end

  describe "#to_hash" do

    it "has name value" do
      h = @tm.to_hash
      h['name'].must_equal "test-timed-value-metric"
    end

    it "has an empty has for additional_data" do
      h = @tm.to_hash
      h['additional_data'].must_equal Hash.new
      h['additional_data'].size.must_equal 0
    end

    it "has a rate" do
      5.times { |x| @tm.start ; sleep 0.05 ; @tm.stop( x ) }
      h = @tm.to_hash
      h['rate'].must_be_close_to(40.0, 1.0)
    end

    it "has a unit_count" do
      5.times { |x| @tm.start ; sleep 0.05 ; @tm.stop( x ) }
      h = @tm.to_hash
      h['unit_count'].must_equal  10
    end

    fields = %w[ name additional_data sampling_start_time sampling_stop_time value_stats timed_stats rate unit_count ]
    fields.each do |f|
      it "has a value for #{f}" do
        3.times { |x| @tm.measure(x) { sleep 0.001 } }
        h = @tm.to_hash
        h[f].wont_be_nil
      end
    end
  end 
end
