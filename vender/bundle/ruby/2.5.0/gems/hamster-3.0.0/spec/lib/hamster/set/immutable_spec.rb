require "spec_helper"
require "hamster/immutable"
require "hamster/set"

describe Hamster::Set do
  it "includes Immutable" do
    Hamster::Set.should include(Hamster::Immutable)
  end
end