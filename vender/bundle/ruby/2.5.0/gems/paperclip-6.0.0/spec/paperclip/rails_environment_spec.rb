require 'spec_helper'

describe Paperclip::RailsEnvironment do

  it "returns nil when Rails isn't defined" do
    resetting_rails_to(nil) do
      expect(Paperclip::RailsEnvironment.get).to be_nil
    end
  end

  it "returns nil when Rails.env isn't defined" do
    resetting_rails_to({}) do
      expect(Paperclip::RailsEnvironment.get).to be_nil
    end
  end

  it "returns the value of Rails.env if it is set" do
    resetting_rails_to(OpenStruct.new(env: "foo")) do
      expect(Paperclip::RailsEnvironment.get).to eq "foo"
    end
  end

  def resetting_rails_to(new_value)
    begin
      previous_rails = Object.send(:remove_const, "Rails")
      Object.const_set("Rails", new_value) unless new_value.nil?
      yield
    ensure
      Object.send(:remove_const, "Rails") if Object.const_defined?("Rails")
      Object.const_set("Rails", previous_rails)
    end
  end
end
