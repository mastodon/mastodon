require "spec_helper"

describe "Fog::StringifyKeys" do
  describe ".stringify" do
    describe "when key is a Symbol" do
      it "replaces key with String" do
        input = { :key => "value" }
        output = Fog::StringifyKeys.stringify(input)
        assert(output.key?("key"))
      end
    end

    describe "when key is a String" do
      it "keeps key as String" do
        input = { "key" => "value" }
        output = Fog::StringifyKeys.stringify(input)
        assert(output.key?("key"))
      end
    end

    describe "when Hash is empty" do
      it "returns empty Hash" do
        assert_equal({}, Fog::StringifyKeys.stringify({}))
      end
    end

    describe "when keys are deeply nested" do
      it "updates only top level key" do
        input = { :key1 => { :key2 => { :key3 => nil }}}

        output = Fog::StringifyKeys.stringify(input)

        expected = { "key1" => { :key2 => { :key3 => nil }}}
        assert_equal(expected, output)
      end
    end
  end
end
