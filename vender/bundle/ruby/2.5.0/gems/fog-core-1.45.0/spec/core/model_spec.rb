require "spec_helper"
require "securerandom"

class FogTestModel < Fog::Model
  identity  :id
end

describe Fog::Model do
  describe "#==" do
    it "is not equal if one is not a Fog::Model" do
      a = FogTestModel.new
      b = 2
      refute_equal a, b
      refute_equal b, a
    end

    it "is equal if it is the same object" do
      a = b = FogTestModel.new
      assert_equal a, b
    end

    it "is equal if it has the same non-nil identity and the same class" do
      id = SecureRandom.hex
      assert_equal FogTestModel.new(:id => id), FogTestModel.new(:id => id)
    end

    it "is not equal if both have nil identity, but are different objects" do
      refute_equal FogTestModel.new, FogTestModel.new
    end

    it "is not equal if it has a different identity" do
      refute_equal FogTestModel.new(:id => SecureRandom.hex),
                   FogTestModel.new(:id => SecureRandom.hex)
    end
  end
end
