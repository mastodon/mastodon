require File.dirname(__FILE__) + '/spec_helper'

describe OEmbed::Formatter do
  include OEmbedSpecHelper

  it "should support JSON" do
    expect {
      OEmbed::Formatter.supported?(:json)
    }.to_not raise_error
  end

  it "should default to JSON" do
    expect(OEmbed::Formatter.default).to eq('json')
  end

  it "should decode a JSON String" do
    decoded = OEmbed::Formatter.decode(:json, valid_response(:json))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    expect(decoded.keys).to eq(valid_response(:object).keys)
    expect(decoded.values.map{|v|v.to_s}).to eq(valid_response(:object).values.map{|v|v.to_s})
  end

  it "should support XML" do
    expect {
      OEmbed::Formatter.supported?(:xml)
    }.to_not raise_error
  end

  it "should decode an XML String" do
    decoded = OEmbed::Formatter.decode(:xml, valid_response(:xml))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    expect(decoded.keys).to eq(valid_response(:object).keys)
    expect(decoded.values.map{|v|v.to_s}).to eq(valid_response(:object).values.map{|v|v.to_s})
  end
end