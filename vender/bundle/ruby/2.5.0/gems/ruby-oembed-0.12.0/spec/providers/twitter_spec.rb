require File.join(File.dirname(__FILE__), '../spec_helper')
require 'support/shared_examples_for_providers'

describe 'OEmbed::Providers::Twitter' do
  before(:all) do
    VCR.insert_cassette('OEmbed_Providers_Twitter')
  end
  after(:all) do
    VCR.eject_cassette
  end

  include OEmbedSpecHelper

  let(:provider_class) { OEmbed::Providers::Twitter }

  expected_valid_urls = %w(
    https://twitter.com/RailsGirlsSoC/status/702136612822634496
    https://www.twitter.com/bpoweski/status/71633762
  )
  expected_invalid_urls = %w(
    http://twitter.com/RailsGirlsSoC/status/702136612822634496
    https://twitter.es/FCBarcelona_es/status/734194638697959424
  )

  it_should_behave_like(
    "an OEmbed::Proviers instance",
    expected_valid_urls,
    expected_invalid_urls
  )

  context "using XML" do
    expected_valid_urls.each do |valid_url|
      context "given the valid URL #{valid_url}" do
        describe ".get" do
          it "should encounter a 400 error" do
            expect {
              provider_class.get(valid_url, :format=>:xml)
            }.to raise_error(OEmbed::UnknownResponse, /\b400\b/)
          end
        end
      end
    end
  end
end
