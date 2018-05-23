require "spec_helper"
require "fog/test_helpers/formats_helper"
require "fog/schema/data_validator"

describe "SchemaValidator" do
  let(:validator) { Fog::Schema::DataValidator.new }

  describe "#validate" do
    it "returns true when value matches schema expectation" do
      assert validator.validate({ "key" => "Value" }, { "key" => String })
    end

    it "returns true when values within an array all match schema expectation" do
      assert validator.validate({ "key" => [1, 2] }, { "key" => [Integer] })
    end

    it "returns true when nested values match schema expectation" do
      assert validator.validate({ "key" => { :nested_key => "Value" } }, { "key" => { :nested_key => String } })
    end

    it "returns true when collection of values all match schema expectation" do
      assert validator.validate([{ "key" => "Value" }, { "key" => "Value" }], [{ "key" => String }])
    end

    it "returns true when collection is empty although schema covers optional members" do
      assert validator.validate([], [{ "key" => String }])
    end

    it "returns true when additional keys are passed and not strict" do
      assert validator.validate({ "key" => "Value", :extra => "Bonus" }, { "key" => String }, { :allow_extra_keys => true })
    end

    it "returns true when value is nil and schema expects NilClass" do
      assert validator.validate({ "key" => nil }, { "key" => NilClass })
    end

    it "returns true when value and schema match as hashes" do
      assert validator.validate({}, {})
    end

    it "returns true when value and schema match as arrays" do
      assert validator.validate([], [])
    end

    it "returns true when value is a Time" do
      assert validator.validate({ "time" => Time.now }, { "time" => Time })
    end

    it "returns true when key is missing but value should be NilClass (#1477)" do
      assert validator.validate({}, { "key" => NilClass }, { :allow_optional_rules => true })
    end

    it "returns true when key is missing but value is nullable (#1477)" do
      assert validator.validate({}, { "key" => Fog::Nullable::String }, { :allow_optional_rules => true })
    end

    it "returns false when value does not match schema expectation" do
      refute validator.validate({ "key" => nil }, { "key" => String })
    end

    it "returns false when key formats do not match" do
      refute validator.validate({ "key" => "Value" }, { :key => String })
    end

    it "returns false when additional keys are passed and strict" do
      refute validator.validate({ "key" => "Missing" }, {})
    end

    it "returns false when some keys do not appear" do
      refute validator.validate({}, { "key" => String })
    end

    it "returns false when collection contains a member that does not match schema" do
      refute validator.validate([{ "key" => "Value" }, { "key" => 5 }], [{ "key" => String }])
    end

    it "returns false when collection has multiple schema patterns" do
      refute validator.validate([{ "key" => "Value" }], [{ "key" => Integer }, { "key" => String }])
    end

    it "returns false when hash and array are compared" do
      refute validator.validate({}, [])
    end

    it "returns false when array and hash are compared" do
      refute validator.validate([], {})
    end

    it "returns false when a hash is expected but another data type is found" do
      refute validator.validate({ "key" => { :nested_key => [] } }, { "key" => { :nested_key => {} } })
    end

    it "returns false when key is missing but value should be NilClass (#1477)" do
      refute validator.validate({}, { "key" => NilClass }, { :allow_optional_rules => false })
    end

    it "returns false when key is missing but value is nullable (#1477)" do
      refute validator.validate({}, { "key" => Fog::Nullable::String }, { :allow_optional_rules => false })
    end
  end
end
