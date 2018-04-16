require "spec_helper"

describe Hitimes::Metric do
  before( :each ) do
    @metric = Hitimes::Metric.new( "testing" )
  end

  it 'has a name' do
    @metric.name.must_equal "testing"
  end

  it "has associated data from initialization" do
    m = Hitimes::Metric.new( "more-data", 'foo' => 'bar', 'this' => 'that' )
    m.additional_data['foo'].must_equal 'bar'
    m.additional_data['this'].must_equal 'that'
    
    m = Hitimes::Metric.new( "more-data", { 'foo' => 'bar', 'this' => 'that' } )
    m.additional_data['foo'].must_equal 'bar'
    m.additional_data['this'].must_equal 'that'
  end

  it "initially has no sampling times" do
    @metric.sampling_start_time.must_be_nil
    @metric.sampling_stop_time.must_be_nil
  end
end

 
