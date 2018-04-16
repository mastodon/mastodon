# frozen_string_literal: true

RSpec.describe HTTP::URI do
  let(:example_http_uri_string)  { "http://example.com" }
  let(:example_https_uri_string) { "https://example.com" }

  subject(:http_uri)  { described_class.parse(example_http_uri_string) }
  subject(:https_uri) { described_class.parse(example_https_uri_string) }

  it "knows URI schemes" do
    expect(http_uri.scheme).to eq "http"
    expect(https_uri.scheme).to eq "https"
  end

  it "sets default ports for HTTP URIs" do
    expect(http_uri.port).to eq 80
  end

  it "sets default ports for HTTPS URIs" do
    expect(https_uri.port).to eq 443
  end

  describe "#dup" do
    it "doesn't share internal value between duplicates" do
      duplicated_uri = http_uri.dup
      duplicated_uri.host = "example.org"

      expect(duplicated_uri.to_s).to eq("http://example.org")
      expect(http_uri.to_s).to eq("http://example.com")
    end
  end
end
