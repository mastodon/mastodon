require File.dirname(__FILE__) + '/../../spec_helper'
require 'json'

describe "Setting JSON.backend = 'JSONGem'" do
  context "without the JSON object defined" do
    it "should fail" do
      expect(OEmbed::Formatter::JSON).to receive(:already_loaded?).with('JSONGem').and_return(false)
      expect(Object).to receive(:const_defined?).with('JSON').and_return(false)

      expect {
        OEmbed::Formatter::JSON.backend = 'JSONGem'
      }.to raise_error(LoadError)
    end
  end

  context "with the JSON object loaded" do
    it "should work" do
      expect(OEmbed::Formatter::JSON).to receive(:already_loaded?).with('JSONGem').and_return(false)

      expect {
        OEmbed::Formatter::JSON.backend = 'JSONGem'
      }.to_not raise_error
    end
  end
end

describe "OEmbed::Formatter::JSON::Backends::JSONGem" do
  include OEmbedSpecHelper

  it "should support JSON" do
    expect {
      OEmbed::Formatter.supported?(:json)
    }.to_not raise_error
  end

  it "should be using the JSONGem backend" do
    expect(OEmbed::Formatter::JSON.backend).to eq(OEmbed::Formatter::JSON::Backends::JSONGem)
  end

  it "should decode a JSON String" do
    decoded = OEmbed::Formatter.decode(:json, valid_response(:json))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    expect(decoded.keys).to eq(valid_response(:object).keys)
    expect(decoded.values.map{|v|v.to_s}).to eq(valid_response(:object).values.map{|v|v.to_s})
  end

  it "should raise an OEmbed::ParseError when decoding an invalid JSON String" do
    expect {
      decode = OEmbed::Formatter.decode(:json, invalid_response('unclosed_container', :json))
    }.to raise_error(OEmbed::ParseError)
    expect {
      decode = OEmbed::Formatter.decode(:json, invalid_response('unclosed_tag', :json))
    }.to raise_error(OEmbed::ParseError)
    expect {
      decode = OEmbed::Formatter.decode(:json, invalid_response('invalid_syntax', :json))
    }.to raise_error(OEmbed::ParseError)
  end

  it "should raise an OEmbed::ParseError when decoding fails with an unexpected error" do
    error_to_raise = ArgumentError
    expect(OEmbed::Formatter::JSON.backend.parse_error).to_not be_kind_of(error_to_raise)

    expect(::JSON).to receive(:parse).
      and_throw(error_to_raise.new("unknown error"))

    expect {
      decode = OEmbed::Formatter.decode(:json, valid_response(:json))
    }.to raise_error(OEmbed::ParseError)
  end
end