require "spec_helper"

describe "credentials" do
  before do
    @old_home = ENV["HOME"]
    @old_rc   = ENV["FOG_RC"]
    @old_credential = ENV["FOG_CREDENTIAL"]
    @old_credentials = Fog.credentials
    Fog.instance_variable_set("@credential_path", nil) # kill memoization
    Fog.instance_variable_set("@credential", nil) # kill memoization
  end

  after do
    ENV["HOME"] = @old_home
    ENV["FOG_RC"] = @old_rc
    ENV["FOG_CREDENTIAL"] = @old_credential
    Fog.credentials = @old_credentials
  end

  describe "credential" do
    it "returns :default for default credentials" do
      assert_equal :default, Fog.credential
    end

    it "returns the to_sym of the assigned value" do
      Fog.credential = "foo"
      assert_equal :foo, Fog.credential
    end

    it "can set credentials throught the FOG_CREDENTIAL env va" do
      ENV["FOG_CREDENTIAL"] = "bar"
      assert_equal :bar, Fog.credential
    end
  end

  describe "credentials_path"  do
    it "has FOG_RC takes precedence over HOME" do
      ENV["HOME"] = "/home/path"
      ENV["FOG_RC"] = "/rc/path"

      assert_equal "/rc/path", Fog.credentials_path
    end

    it "properly expands paths" do
      ENV["FOG_RC"] = "/expanded/subdirectory/../path"
      assert_equal "/expanded/path", Fog.credentials_path
    end

    it "falls back to home path if FOG_RC not set" do
      ENV.delete("FOG_RC")
      assert_equal File.join(ENV["HOME"], ".fog"), Fog.credentials_path
    end

    it "ignores home path if it does not exist" do
      ENV.delete("FOG_RC")
      ENV["HOME"] = "/no/such/path"
      assert_nil Fog.credentials_path
    end

    it "File.expand_path raises because of non-absolute path" do
      ENV.delete("FOG_RC")
      ENV["HOME"] = "."

      if RUBY_PLATFORM == "java"
        Fog::Logger.warning("Stubbing out non-absolute path credentials test due to JRuby bug: https://github.com/jruby/jruby/issues/1163")
      else
        assert_nil Fog.credentials_path
      end
    end

    it "returns nil when neither FOG_RC or HOME are set" do
      ENV.delete("HOME")
      ENV.delete("FOG_RC")
      assert_nil Fog.credentials_path
    end
  end

  describe "symbolize_credential?" do
    it "returns false if the value is :headers" do
      refute Fog.symbolize_credential?(:headers)
    end

    it "returns true if the value is not :headers" do
      assert Fog.symbolize_credential?(:foo)
      assert Fog.symbolize_credential?(:liberate_me_ex_inheris)
    end
  end
end
