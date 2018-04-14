require 'spec_helper'
require 'json'

describe Hitimes::Stats do
  before( :each ) do
    @stats = Hitimes::Stats.new
    @full_stats = Hitimes::Stats.new
    
    [ 1, 2, 3].each { |i| @full_stats.update( i ) }
  end

  it "is initialized with 0 values" do
    @stats.count.must_equal 0
    @stats.min.must_equal 0.0
    @stats.max.must_equal 0.0
    @stats.sum.must_equal 0.0
    @stats.rate.must_equal 0.0
  end

  it "calculates the mean correctly" do
    @full_stats.mean.must_equal 2.0
  end

  it "calculates the rate correctly" do
    @full_stats.rate.must_equal 0.5
  end

  it "tracks the maximum value" do
    @full_stats.max.must_equal 3.0
  end

  it "tracks the minimum value" do
    @full_stats.min.must_equal 1.0
  end

  it "tracks the count" do
    @full_stats.count.must_equal 3
  end
  
  it "tracks the sum" do
    @full_stats.sum.must_equal 6.0
  end

  it "calculates the standard deviation" do
    @full_stats.stddev.must_equal 1.0
  end 

  it "calculates the sum of squares " do
    @full_stats.sumsq.must_equal 14.0
  end 

  describe "#to_hash " do
    it "converts to a Hash" do
      h = @full_stats.to_hash
      h.size.must_equal ::Hitimes::Stats::STATS.size
      h.keys.sort.must_equal ::Hitimes::Stats::STATS
    end

    it "converts to a limited Hash if given arguments" do
      h = @full_stats.to_hash( "min", "max", "mean" )
      h.size.must_equal 3
      h.keys.sort.must_equal %w[ max mean min  ]

      h = @full_stats.to_hash( %w[ count rate ] )
      h.size.must_equal 2
      h.keys.sort.must_equal %w[ count rate ]
    end

    it "raises NoMethodError if an invalid stat is used" do
      lambda { @full_stats.to_hash( "wibble" ) }.must_raise( NoMethodError )
    end
  end

  describe "#to_json" do
    it "converts to a json string" do
      j = @full_stats.to_json
      h = JSON.parse( j )
      h.size.must_equal ::Hitimes::Stats::STATS.size
      h.keys.sort.must_equal ::Hitimes::Stats::STATS
    end

    it "converts to a limited Hash if given arguments" do
      j = @full_stats.to_json( "min", "max", "mean" )
      h = JSON.parse( j )
      h.size.must_equal 3
      h.keys.sort.must_equal %w[ max mean min  ]

      j = @full_stats.to_json( %w[ count rate ] )
      h = JSON.parse( j )
      h.size.must_equal 2
      h.keys.sort.must_equal %w[ count rate ]
    end

    it "raises NoMethodError if an invalid stat is used" do
      lambda { @full_stats.to_json( "wibble" ) }.must_raise( NoMethodError )
    end
  end
end
