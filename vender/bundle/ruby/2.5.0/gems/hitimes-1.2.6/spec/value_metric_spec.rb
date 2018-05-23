require 'spec_helper'

describe Hitimes::ValueMetric do
  before( :each ) do
    @metric = Hitimes::ValueMetric.new( "testing" )
    10.times { |x| @metric.measure( x ) }
  end

  it 'has a name' do
    @metric.name.must_equal "testing"
  end

  it "has associated data from initialization" do
    m = Hitimes::ValueMetric.new( "more-data", 'foo' => 'bar', 'this' => 'that' )
    m.additional_data['foo'].must_equal 'bar'
    m.additional_data['this'].must_equal 'that'
    
    m = Hitimes::ValueMetric.new( "more-data", { 'foo' => 'bar', 'this' => 'that' } )
    m.additional_data['foo'].must_equal 'bar'
    m.additional_data['this'].must_equal 'that'
  end

  it "calculates the mean of the measurements" do
    @metric.mean.must_equal 4.5
  end

  it "calculates the stddev of the measurements" do
    @metric.stddev.must_be :>, 0.0
  end

  it "returns 0.0 for stddev if there is no data" do
    m = Hitimes::ValueMetric.new('0-data')
    m.stddev.must_equal 0.0
  end

  it "keeps track of the sum of data" do
    @metric.sum.must_equal 45.0
  end

  it "keeps track of the sum of squars of data" do
    @metric.sumsq.must_equal 285.0
  end

  it "retuns 0.0 for mean if there is no data" do
    Hitimes::ValueMetric.new('0-data').mean.must_equal 0.0
  end

  it "keeps track of the min value" do
    @metric.min.must_equal 0
  end

  it "keeps track of the max value" do
    @metric.max.must_equal 9
  end

  it "keeps track of the first start time of all the measurements" do
    m = Hitimes::ValueMetric.new( "first-start-time" )
    f1 = Time.now.gmtime.to_f * 1_000_000
    10.times{ |x| m.measure( x ); sleep 0.1 }
    f2 = Time.now.gmtime.to_f * 1_000_000
    m.sampling_start_time.must_be :>=, f1
    m.sampling_start_time.must_be :<, f2
    # distance from now to start time should be greater than the distance from
    # the start to the min start_time
    (f2 - m.sampling_start_time).must_be :>, ( m.sampling_start_time - f1 )
  end

  it "keeps track of the last stop time of all the intervals" do
    m = Hitimes::ValueMetric.new( "last-stop-time" )
    f1 = Time.now.gmtime.to_f * 1_000_000
    10.times {|x| m.measure( x ); sleep 0.1  }
    f2 = Time.now.gmtime.to_f * 1_000_000
    m.sampling_stop_time.must_be :>, f1
    m.sampling_stop_time.must_be :<=, f2
    # distance from now to max stop time time should be less than the distance
    # from the start to the max stop time
    (f2 - m.sampling_stop_time).must_be :<, ( m.sampling_stop_time - f1 )
  end

  describe "#to_hash" do

    it "has name value" do
      h = @metric.to_hash
      h['name'].must_equal "testing"
    end

    it "has an empty has for additional_data" do
      h = @metric.to_hash
      h['additional_data'].must_equal Hash.new
      h['additional_data'].size.must_equal 0
    end

    it "has the right sum" do
      h = @metric.to_hash
      h['sum'].must_equal 45
    end

    fields = ::Hitimes::Stats::STATS.dup + %w[ name additional_data sampling_start_time sampling_stop_time ]
    fields = fields - [ 'rate' ]
    fields.each do |f|
      it "has a value for #{f}" do
        h = @metric.to_hash
        h[f].wont_be_nil
      end
    end
  end
end

