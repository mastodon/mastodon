require File.dirname(__FILE__) + '/spec_helper'
require 'json'

describe OEmbed::ProviderDiscovery do
  before(:all) do
    OEmbed::Formatter::JSON.backend = 'JSONGem'
    VCR.insert_cassette('OEmbed_ProviderDiscovery')
  end
  after(:all) do
    VCR.eject_cassette
  end

  include OEmbedSpecHelper

  {
    # 'name' => [
    #   'given_page_url',
    #   'expected_endpoint' || {:json=>'expected_json_endpoint', :xml=>'expected_xml_endpoint},
    #   :expected_format,
    # ]
    'youtube' => [
      'http://www.youtube.com/watch?v=u6XAPnuFjJc',
      {:json=>'http://www.youtube.com/oembed', :xml=>'http://www.youtube.com/oembed'},
      :json,
    ],
    'vimeo' => [
      'http://vimeo.com/27953845',
      {:json=>'http://vimeo.com/api/oembed.json', :xml=>'http://vimeo.com/api/oembed.xml'},
      :json,
    ],
    'facebook-photo' => [
      'https://www.facebook.com/Federer/photos/pb.64760994940.-2207520000.1456668968./10153235368269941/?type=3&theater',
      'https://www.facebook.com/plugins/post/oembed.json/',
      :json,
    ],
    'tumblr' => [
      'http://kittehkats.tumblr.com/post/140525169406/katydid-and-the-egg-happy-forest-family',
      'https://www.tumblr.com/oembed/1.0',
      :json
    ],
    'noteflight' => [
      'http://www.noteflight.com/scores/view/09665392c94475f65dfaf5f30aadb6ed0921939d',
      {:json=>'http://www.noteflight.com/services/oembed', :xml=>'http://www.noteflight.com/services/oembed'},
      :json,
    ],
    # TODO: Enhance ProviderDiscovery to support arbitrary query parameters. See https://github.com/ruby-oembed/ruby-oembed/issues/15
    #'wordpress' => [
    #  'http://sweetandweak.wordpress.com/2011/09/23/nothing-starts-the-morning-like-a-good-dose-of-panic/',
    #  {:json=>'https://public-api.wordpress.com/oembed/1.0/', :xml=>'https://public-api.wordpress.com/oembed/1.0/'},
    #  :json,
    #],
  }.each do |context, urls|

    given_url, expected_endpoints, expected_format = urls
    expected_endpoints = {expected_format=>expected_endpoints} unless expected_endpoints.is_a?(Hash)

    context "given a #{context} url" do

      shared_examples "a discover_provider call" do |endpoint, format|
        describe ".discover_provider" do
          it "should return the correct Class" do
            expect(provider).to be_instance_of(OEmbed::Provider)
          end

          it "should detect the correct URL" do
            expect(provider.endpoint).to eq(endpoint)
          end

          it "should return the correct format" do
            expect(provider.format).to eq(format)
          end
        end

        describe ".get" do
          it "should return the correct Class" do
            expect(response).to be_kind_of(OEmbed::Response)
          end

          it "should return the correct format" do
            expect(response.format).to eq(format.to_s)
          end

          it "should return the correct data" do
            expect(response.type).to_not be_empty

            case response.type
            when 'video', 'rich'
              expect(response.html).to_not be_empty
              expect(response.width).to_not be_nil
              expect(response.height).to_not be_nil
            when 'photo'
              expect(response.url).to_not be_empty
              expect(response.width).to_not be_nil
              expect(response.height).to_not be_nil
            end
          end
        end # get
      end

      context "with no format specified" do
        let(:provider) { OEmbed::ProviderDiscovery.discover_provider(given_url) }
        let(:response) { OEmbed::ProviderDiscovery.get(given_url) }
        include_examples "a discover_provider call", expected_endpoints[expected_format], expected_format
      end

      if expected_endpoints.include?(:json)
        context "with json format specified" do
          let(:provider) { OEmbed::ProviderDiscovery.discover_provider(given_url, :format=>:json) }
          let(:response) { OEmbed::ProviderDiscovery.get(given_url, :format=>:json) }
          include_examples "a discover_provider call", expected_endpoints[:json], :json
        end
      end

      if expected_endpoints.include?(:xml)
        context "with json format specified" do
          let(:provider) { OEmbed::ProviderDiscovery.discover_provider(given_url, :format=>:xml) }
          let(:response) { OEmbed::ProviderDiscovery.get(given_url, :format=>:xml) }
          include_examples "a discover_provider call", expected_endpoints[:xml], :xml
        end
      end
    end

  end # each service

  context "when returning 404" do
    let(:url) { 'https://www.youtube.com/watch?v=123123123' }

    it "raises OEmbed::NotFound" do
      expect{ OEmbed::ProviderDiscovery.discover_provider(url) }.to raise_error(OEmbed::NotFound)
    end
  end

  context "when returning 301" do
    let(:url) { 'http://www.youtube.com/watch?v=dFs9WO2B8uI' }

    it "does redirect http to https" do
      expect{ OEmbed::ProviderDiscovery.discover_provider(url) }.not_to raise_error
    end
  end

  it "does passes the timeout option to Net::Http" do
    expect_any_instance_of(Net::HTTP).to receive(:open_timeout=).with(5)
    expect_any_instance_of(Net::HTTP).to receive(:read_timeout=).with(5)
    OEmbed::ProviderDiscovery.discover_provider('https://www.youtube.com/watch?v=dFs9WO2B8uI', :timeout => 5)
  end
end
