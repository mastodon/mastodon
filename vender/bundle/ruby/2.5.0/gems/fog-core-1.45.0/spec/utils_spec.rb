require "spec_helper"

describe Fog::Core::Utils do
  describe "prepare_service_settings" do
    it "changes String keys to be Symbols" do
      settings = { "a" => 3 }
      expected = { :a => 3 }
      assert_equal expected, Fog::Core::Utils.prepare_service_settings(settings)
    end

    it "leaves Symbol keys unchanged" do
      settings = { :something => 2 }
      expected = { :something => 2 }
      assert_equal expected, Fog::Core::Utils.prepare_service_settings(settings)
    end

    it "changes nested String keys to Symbols" do
      settings = { "connection_options" => { "val" => 5 } }
      expected = { :connection_options => { :val => 5 } }
      assert_equal expected, Fog::Core::Utils.prepare_service_settings(settings)
    end

    it "does not change the :header key or contents" do
      settings = { :headers => { "User-Agent" => "my user agent" } }
      expected = { :headers => { "User-Agent" => "my user agent" } }
      assert_equal expected, Fog::Core::Utils.prepare_service_settings(settings)
    end
  end
end
