require "spec_helper"
require "fog/test_helpers/formats_helper"
require "fog/test_helpers/types_helper"

module Shindo
  class Tests
    def test(_str, &_block)
      yield
    end
  end
end

describe "formats_helper" do
  let(:shindo) { Shindo::Tests.new }

  it "comparing welcome data against schema" do
    data = { :welcome => "Hello" }
    assert shindo.data_matches_schema(:welcome => String) { data }
  end

  describe "#data_matches_schema" do
    it "when value matches schema expectation" do
      assert shindo.data_matches_schema("key" => String) { { "key" => "Value" } }
    end

    it "when values within an array all match schema expectation" do
      assert shindo.data_matches_schema("key" => [Integer]) { { "key" => [1, 2] } }
    end

    it "when nested values match schema expectation" do
      assert shindo.data_matches_schema("key" => { :nested_key => String }) { { "key" => { :nested_key => "Value" } } }
    end

    it "when collection of values all match schema expectation" do
      assert shindo.data_matches_schema([{ "key" => String }]) { [{ "key" => "Value" }, { "key" => "Value" }] }
    end

    it "when collection is empty although schema covers optional members" do
      assert shindo.data_matches_schema([{ "key" => String }], :allow_optional_rules => true) { [] }
    end

    it "when additional keys are passed and not strict" do
      assert shindo.data_matches_schema({ "key" => String }, { :allow_extra_keys => true }) { { "key" => "Value", :extra => "Bonus" } }
    end

    it "when value is nil and schema expects NilClass" do
      assert shindo.data_matches_schema("key" => NilClass) { { "key" => nil } }
    end

    it "when value and schema match as hashes" do
      assert shindo.data_matches_schema({}) { {} }
    end

    it "when value and schema match as arrays" do
      assert shindo.data_matches_schema([]) { [] }
    end

    it "when value is a Time" do
      assert shindo.data_matches_schema("time" => Time) { { "time" => Time.now } }
    end

    it "when key is missing but value should be NilClass (#1477)" do
      assert shindo.data_matches_schema({ "key" => NilClass }, { :allow_optional_rules => true }) { {} }
    end

    it "when key is missing but value is nullable (#1477)" do
      assert shindo.data_matches_schema({ "key" => Fog::Nullable::String }, { :allow_optional_rules => true }) { {} }
    end
  end

  describe "#formats backwards compatible changes" do

    it "when value matches schema expectation" do
      assert shindo.formats("key" => String) { { "key" => "Value" } }
    end

    it "when values within an array all match schema expectation" do
      assert shindo.formats("key" => [Integer]) { { "key" => [1, 2] } }
    end

    it "when nested values match schema expectation" do
      assert shindo.formats("key" => { :nested_key => String }) { { "key" => { :nested_key => "Value" } } }
    end

    it "when collection of values all match schema expectation" do
      assert shindo.formats([{ "key" => String }]) { [{ "key" => "Value" }, { "key" => "Value" }] }
    end

    it "when collection is empty although schema covers optional members" do
      assert shindo.formats([{ "key" => String }]) { [] }
    end

    it "when additional keys are passed and not strict" do
      assert shindo.formats({ "key" => String }, false) { { "key" => "Value", :extra => "Bonus" } }
    end

    it "when value is nil and schema expects NilClass" do
      assert shindo.formats("key" => NilClass) { { "key" => nil } }
    end

    it "when value and schema match as hashes" do
      assert shindo.formats({}) { {} }
    end

    it "when value and schema match as arrays" do
      assert shindo.formats([]) { [] }
    end

    it "when value is a Time" do
      assert shindo.formats("time" => Time) { { "time" => Time.now } }
    end

    it "when key is missing but value should be NilClass (#1477)" do
      assert shindo.formats("key" => NilClass) { {} }
    end

    it "when key is missing but value is nullable (#1477)" do
      assert shindo.formats("key" => Fog::Nullable::String) { {} }
    end
  end
end
