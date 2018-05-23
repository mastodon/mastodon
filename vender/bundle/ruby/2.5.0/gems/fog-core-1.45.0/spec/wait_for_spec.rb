require "spec_helper"

describe "Fog#wait_for" do
  it "returns a Hash indicating the wait duration if successful" do
    assert_equal({ :duration => 0 }, Fog.wait_for(1) { true })
  end

  it "raises if the wait timeout is exceeded" do
    assert_raises(Fog::Errors::TimeoutError) do
      Fog.wait_for(2) { false }
    end
  end

  it "does not raise if successful when the wait timeout is exceeded" do
    timeout = 2
    i = 0
    ret = Fog.wait_for(timeout) { i = i + 1; i > 2 }
    assert_operator(ret[:duration], :>, timeout)
  end

  it "accepts a proc to determine the sleep interval" do
    i = 0
    ret = Fog.wait_for(1, lambda { |_t| 1 }) do
      i += 1
      i > 1
    end
    assert(1 <= ret[:duration])
    assert(ret[:duration] < 2)
  end
end
