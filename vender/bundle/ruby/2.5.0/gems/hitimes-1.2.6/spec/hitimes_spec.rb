require 'spec_helper'

describe Hitimes do
  it "can time a block of code" do
    d = Hitimes.measure do
      sleep 0.2
    end
    d.must_be_close_to(0.2, 0.002)
  end

  it "raises an error if measure is called with no block" do
    lambda{ Hitimes.measure }.must_raise( Hitimes::Error )
  end
end
