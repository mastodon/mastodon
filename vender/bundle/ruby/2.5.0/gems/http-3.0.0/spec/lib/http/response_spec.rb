# frozen_string_literal: true

RSpec.describe HTTP::Response do
  let(:body)          { "Hello world!" }
  let(:uri)           { "http://example.com/" }
  let(:headers)       { {} }

  subject(:response) do
    HTTP::Response.new(
      :status  => 200,
      :version => "1.1",
      :headers => headers,
      :body    => body,
      :uri     => uri
    )
  end

  it "includes HTTP::Headers::Mixin" do
    expect(described_class).to include HTTP::Headers::Mixin
  end

  describe "to_a" do
    let(:body)         { "Hello world" }
    let(:content_type) { "text/plain" }
    let(:headers)      { {"Content-Type" => content_type} }

    it "returns a Rack-like array" do
      expect(subject.to_a).to eq([200, headers, body])
    end
  end

  describe "#content_length" do
    subject { response.content_length }

    context "without Content-Length header" do
      it { is_expected.to be_nil }
    end

    context "with Content-Length: 5" do
      let(:headers) { {"Content-Length" => "5"} }
      it { is_expected.to eq 5 }
    end

    context "with invalid Content-Length" do
      let(:headers) { {"Content-Length" => "foo"} }
      it { is_expected.to be_nil }
    end
  end

  describe "mime_type" do
    subject { response.mime_type }

    context "without Content-Type header" do
      let(:headers) { {} }
      it { is_expected.to be_nil }
    end

    context "with Content-Type: text/html" do
      let(:headers) { {"Content-Type" => "text/html"} }
      it { is_expected.to eq "text/html" }
    end

    context "with Content-Type: text/html; charset=utf-8" do
      let(:headers) { {"Content-Type" => "text/html; charset=utf-8"} }
      it { is_expected.to eq "text/html" }
    end
  end

  describe "charset" do
    subject { response.charset }

    context "without Content-Type header" do
      let(:headers) { {} }
      it { is_expected.to be_nil }
    end

    context "with Content-Type: text/html" do
      let(:headers) { {"Content-Type" => "text/html"} }
      it { is_expected.to be_nil }
    end

    context "with Content-Type: text/html; charset=utf-8" do
      let(:headers) { {"Content-Type" => "text/html; charset=utf-8"} }
      it { is_expected.to eq "utf-8" }
    end
  end

  describe "#parse" do
    let(:headers)   { {"Content-Type" => content_type} }
    let(:body)      { '{"foo":"bar"}' }

    context "with known content type" do
      let(:content_type) { "application/json" }
      it "returns parsed body" do
        expect(response.parse).to eq "foo" => "bar"
      end
    end

    context "with unknown content type" do
      let(:content_type) { "application/deadbeef" }
      it "raises HTTP::Error" do
        expect { response.parse }.to raise_error HTTP::Error
      end
    end

    context "with explicitly given mime type" do
      let(:content_type) { "application/deadbeef" }
      it "ignores mime_type of response" do
        expect(response.parse("application/json")).to eq "foo" => "bar"
      end

      it "supports MIME type aliases" do
        expect(response.parse(:json)).to eq "foo" => "bar"
      end
    end
  end

  describe "#flush" do
    let(:body) { double :to_s => "" }

    it "returns response self-reference" do
      expect(response.flush).to be response
    end

    it "flushes body" do
      expect(body).to receive :to_s
      response.flush
    end
  end

  describe "#inspect" do
    let(:headers) { {:content_type => "text/plain"} }
    let(:body)    { double :to_s => "foobar" }

    it "returns human-friendly response representation" do
      expect(response.inspect).
        to eq '#<HTTP::Response/1.1 200 OK {"Content-Type"=>"text/plain"}>'
    end
  end

  describe "#cookies" do
    let(:cookies) { ["a=1", "b=2; domain=example.com", "c=3; domain=bad.org"] }
    let(:headers) { {"Set-Cookie" => cookies} }

    subject(:jar) { response.cookies }

    it { is_expected.to be_an HTTP::CookieJar }

    it "contains cookies without domain restriction" do
      expect(jar.count { |c| "a" == c.name }).to eq 1
    end

    it "contains cookies limited to domain of request uri" do
      expect(jar.count { |c| "b" == c.name }).to eq 1
    end

    it "does not contains cookies limited to non-requeted uri" do
      expect(jar.count { |c| "c" == c.name }).to eq 0
    end
  end

  describe "#connection" do
    let(:connection) { double }

    subject(:response) do
      HTTP::Response.new(
        :version    => "1.1",
        :status     => 200,
        :connection => connection
      )
    end

    it "returns the connection object used to instantiate the response" do
      expect(response.connection).to eq connection
    end
  end

  describe "#chunked?" do
    subject { response }
    context "when encoding is set to chunked" do
      let(:headers) { {"Transfer-Encoding" => "chunked"} }
      it { is_expected.to be_chunked }
    end
    it { is_expected.not_to be_chunked }
  end
end
