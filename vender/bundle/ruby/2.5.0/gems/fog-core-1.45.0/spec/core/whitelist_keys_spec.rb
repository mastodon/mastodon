require "spec_helper"

describe "Fog::WhitelistKeys" do
  describe ".whitelist" do
    describe "when other keys are present" do
      it "returns Hash with only allowed keys" do
        input = { :name => "name", :type => "type", :size => 80 }
        valid_keys = %w(name size)

        output = Fog::WhitelistKeys.whitelist(input, valid_keys)

        expected = { "name" => "name", "size" => 80 }
        assert_equal(expected, output)
      end
    end

    describe "when key is a Symbol" do
      it "returns a String" do
        input = { :name => "name" }
        valid_keys = %w(name)

        output = Fog::WhitelistKeys.whitelist(input, valid_keys)

        expected = { "name" => "name" }
        assert(expected, output)
      end
    end

    describe "when Hash is empty" do
      it "returns empty Hash" do
        output = Fog::WhitelistKeys.whitelist({}, [])
        assert_equal({}, output)
      end
    end
  end
end
