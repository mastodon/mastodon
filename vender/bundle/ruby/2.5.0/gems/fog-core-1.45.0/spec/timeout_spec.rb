require "spec_helper"

describe "Fog#timeout" do
  before do
    @old_timeout = Fog.timeout
  end

  after do
    Fog.timeout = @old_timeout
  end

  it "defaults to 600" do
    assert_equal 600, Fog.timeout
  end

  it "can be reassigned through Fog#timeout=" do
    Fog.timeout = 300
    assert_equal 300, Fog.timeout
  end
end
