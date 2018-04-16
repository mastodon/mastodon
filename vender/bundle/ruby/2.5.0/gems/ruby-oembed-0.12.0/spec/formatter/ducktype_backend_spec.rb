require File.dirname(__FILE__) + '/../spec_helper'

class WorkingDuck
  # The WorkingDuck Class should work as a Backend
  class << self
    # Fakes a correct deocde response
    def decode(value)
      {"version"=>1.0, "string"=>"test", "int"=>42, "html"=>"<i>Cool's</i>\n the \"word\"!",}
    end
    def parse_error; RuntimeError; end
  end

  # A WorkingDuck instance should work as a Backend
  def decode(value)
    self.class.decode(value)
  end
  def parse_error; RuntimeError; end
end

class FailingDuckDecode
  # Fakes an incorrect decode response
  def decode(value)
    {}
  end
  def parse_error; RuntimeError; end
end

describe "OEmbed::Formatter::JSON::Backends::DuckType" do
  include OEmbedSpecHelper

  it "should work with WorkingDuck Class" do
    expect {
      OEmbed::Formatter::JSON.backend = WorkingDuck
    }.not_to raise_error
    expect(OEmbed::Formatter::JSON.backend).to be WorkingDuck
  end

  it "should work with a WorkingDuck instance" do
    instance = WorkingDuck.new
    expect {
      OEmbed::Formatter::JSON.backend = instance
    }.to_not raise_error
    expect(OEmbed::Formatter::JSON.backend).to be instance
  end

  it "should fail with FailingDuckDecode Class" do
    expect {
      OEmbed::Formatter::JSON.backend = FailingDuckDecode
    }.to raise_error(LoadError)
    expect(OEmbed::Formatter::JSON.backend).to_not be(FailingDuckDecode)
  end

  it "should fail with a FailingDuckDecode instance" do
    instance = FailingDuckDecode.new
    expect {
      OEmbed::Formatter::JSON.backend = instance
    }.to raise_error(LoadError)
    expect(OEmbed::Formatter::JSON.backend).to_not be(instance)
  end
end

describe "OEmbed::Formatter::XML::Backends::DuckType" do
  include OEmbedSpecHelper

  it "should work with WorkingDuck Class" do
    expect {
      OEmbed::Formatter::XML.backend = WorkingDuck
    }.to_not raise_error
    expect(OEmbed::Formatter::XML.backend).to be(WorkingDuck)
  end

  it "should work with a WorkingDuck instance" do
    instance = WorkingDuck.new
    expect {
      OEmbed::Formatter::XML.backend = instance
    }.to_not raise_error
    expect(OEmbed::Formatter::XML.backend).to be(instance)
  end

  it "should fail with FailingDuckDecode Class" do
    expect {
      OEmbed::Formatter::XML.backend = FailingDuckDecode
    }.to raise_error(LoadError)
    expect(OEmbed::Formatter::XML.backend).to_not be(FailingDuckDecode)
  end

  it "should fail with a FailingDuckDecode instance" do
    instance = FailingDuckDecode.new
    expect {
      OEmbed::Formatter::XML.backend = instance
    }.to raise_error(LoadError)
    expect(OEmbed::Formatter::XML.backend).to_not be(instance)
  end
end