require File.dirname(__FILE__) + '/spec_helper'

def expected_helpers
  {
    "type" => "random",
    "version" => "1.0",
    "html" => "&lt;em&gt;Hello world!&lt;/em&gt;",
    "url" => "http://foo.com/bar",
  }.freeze
end

def expected_skipped
  {
    "fields" => "hello",
    "__id__" => 1234,
    "provider" => "oohEmbed",
    "to_s" => "random string",
  }.freeze
end

def all_expected
  expected_helpers.merge(expected_skipped).freeze
end

describe OEmbed::Response do
  include OEmbedSpecHelper

  let(:flickr) {
    flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    flickr << "http://*.flickr.com/*"
    flickr
  }

  let(:skitch) {
    OEmbed::Provider.new("https://skitch.com/oembed")
  }

  let(:qik) {
    qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}", :xml)
    qik << "http://qik.com/video/*"
    qik << "http://qik.com/*"
    qik
  }

  let(:viddler) {
    viddler = OEmbed::Provider.new("http://lab.viddler.com/services/oembed/", :json)
    viddler << "http://*.viddler.com/*"
    viddler
  }

  let(:new_res) {
    OEmbed::Response.new(valid_response(:object), OEmbed::Providers::OohEmbed)
  }

  let(:default_res) {
    OEmbed::Response.create_for(valid_response(:json), @flickr, example_url(:flickr), :json)
  }

  let(:xml_res) {
    OEmbed::Response.create_for(valid_response(:xml), @qik, example_url(:qik), :xml)
  }

  let(:json_res) {
    OEmbed::Response.create_for(valid_response(:json), @viddler, example_url(:viddler), :json)
  }

  describe "#initialize" do
    it "should parse the data into fields" do
      # We need to compare keys & values separately because we don't expect all
      # non-string values to be recognized correctly.

      expect(new_res.fields.keys).to eq(valid_response(:object).keys)
      expect(new_res.fields.values.map{|v|v.to_s}).to eq(valid_response(:object).values.map{|v|v.to_s})

      expect(default_res.fields.keys).to eq(valid_response(:object).keys)
      expect(default_res.fields.values.map{|v|v.to_s}).to eq(valid_response(:object).values.map{|v|v.to_s})

      expect(xml_res.fields.keys).to eq(valid_response(:object).keys)
      expect(xml_res.fields.values.map{|v|v.to_s}).to eq(valid_response(:object).values.map{|v|v.to_s})

      expect(json_res.fields.keys).to eq(valid_response(:object).keys)
      expect(json_res.fields.values.map{|v|v.to_s}).to eq(valid_response(:object).values.map{|v|v.to_s})
    end

    it "should set the provider" do
      expect(new_res.provider).to eq(OEmbed::Providers::OohEmbed)
      expect(default_res.provider).to eq(@flickr)
      expect(xml_res.provider).to eq(@qik)
      expect(json_res.provider).to eq(@viddler)
    end

    it "should set the format" do
      expect(new_res.format).to be_nil
      expect(default_res.format.to_s).to eq('json')
      expect(xml_res.format.to_s).to eq('xml')
      expect(json_res.format.to_s).to eq('json')
    end

    it "should set the request_url" do
      expect(new_res.request_url).to be_nil
      expect(default_res.request_url.to_s).to eq(example_url(:flickr))
      expect(xml_res.request_url.to_s).to eq(example_url(:qik))
      expect(json_res.request_url.to_s).to eq(example_url(:viddler))
    end
  end

  describe "create_for" do
    it "should only allow JSON or XML" do
      expect {
        OEmbed::Response.create_for(valid_response(:json), flickr, example_url(:flickr), :json)
      }.not_to raise_error

      expect {
        OEmbed::Response.create_for(valid_response(:xml), flickr, example_url(:flickr), :xml)
      }.not_to raise_error

      expect {
        OEmbed::Response.create_for(valid_response(:yml), flickr, example_url(:flickr), :yml)
      }.to raise_error(OEmbed::FormatNotSupported)
    end

    it "should not parse the incorrect format" do
      expect {
        OEmbed::Response.create_for(valid_response(:object), example_url(:flickr), flickr, :json)
      }.to raise_error(OEmbed::ParseError)

      expect {
        OEmbed::Response.create_for(valid_response(:xml), example_url(:flickr), viddler, :json)
      }.to raise_error(OEmbed::ParseError)

      expect {
        OEmbed::Response.create_for(valid_response(:json), example_url(:flickr), viddler, :xml)
      }.to raise_error(OEmbed::ParseError)
    end
  end

  it "should access the XML data through #field" do
    expect(xml_res.field(:type)).to eq("photo")
    expect(xml_res.field(:version)).to eq("1.0")
    expect(xml_res.field(:fields)).to eq("hello")
    expect(xml_res.field(:__id__)).to eq("1234")
  end

  it "should access the JSON data through #field" do
    expect(json_res.field(:type)).to eq("photo")
    expect(json_res.field(:version)).to eq("1.0")
    expect(json_res.field(:fields)).to eq("hello")
    expect(json_res.field(:__id__)).to eq("1234")
  end

  describe "#define_methods!" do
    context "with automagic" do
      all_expected.each do |method, value|
        before do
          @local_res = OEmbed::Response.new(all_expected, OEmbed::Providers::OohEmbed)
        end

        it "should define the #{method} method" do
          expect(@local_res).to respond_to(method)
        end
      end

      expected_helpers.each do |method, value|
        it "should define #{method} to return #{value.inspect}" do
          expect(@local_res.send(method)).to eq(value)
        end
      end

      expected_skipped.each do |method, value|
        it "should NOT override #{method} to not return #{value.inspect}" do
          expect(@local_res.send(method)).to_not eq(value)
        end
      end
    end

    it "should protect most already defined methods" do
      expect(Object.new).to respond_to('__id__')
      expect(Object.new).to respond_to('to_s')

      expect(all_expected.keys).to include('__id__')
      expect(all_expected.keys).to include('to_s')

      local_res = OEmbed::Response.new(all_expected, OEmbed::Providers::OohEmbed)

      expect(local_res.__id__).to_not eq(local_res.field('__id__'))
      expect(local_res.to_s).to_not eq(local_res.field('to_s'))
    end

    it "should not protect already defined methods that are specifically overridable" do
      class Object
        def version
          "two point oh"
        end
      end

      expect(Object.new).to respond_to('version')
      expect(String.new).to respond_to('version')

      expect(all_expected.keys).to include('version')
      expect(all_expected['version']).to_not eq(String.new.version)

      local_res = OEmbed::Response.new(all_expected, OEmbed::Providers::OohEmbed)

      expect(local_res.version).to eq(local_res.field('version'))
      expect(local_res.version).to_not eq(String.new.version)
    end
  end

  describe "OEmbed::Response::Photo" do
    describe "#html" do
      it "should include the title, if given" do
        response = OEmbed::Response.create_for(example_body(:flickr), example_url(:flickr), flickr, :json)
        expect(response).to respond_to(:title)
        expect(response.title).to_not be_empty

        expect(response.html).to_not be_nil
        expect(response.html).to match(/alt='#{response.title}'/)
      end

      it "should work just fine, without a title" do
        response = OEmbed::Response.create_for(example_body(:skitch), example_url(:skitch), skitch, :json)
        expect(response).to_not respond_to(:title)

        expect(response.html).to_not be_nil
        expect(response.html).to match(/alt=''/)
      end
    end
  end

end
