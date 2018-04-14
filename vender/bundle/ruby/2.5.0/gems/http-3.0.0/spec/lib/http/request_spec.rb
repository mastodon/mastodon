# frozen_string_literal: true
# coding: utf-8

RSpec.describe HTTP::Request do
  let(:proxy)       { {} }
  let(:headers)     { {:accept => "text/html"} }
  let(:request_uri) { "http://example.com/foo?bar=baz" }

  subject :request do
    HTTP::Request.new(
      :verb     => :get,
      :uri      => request_uri,
      :headers  => headers,
      :proxy    => proxy
    )
  end

  it "includes HTTP::Headers::Mixin" do
    expect(described_class).to include HTTP::Headers::Mixin
  end

  it "requires URI to have scheme part" do
    expect { HTTP::Request.new(:verb => :get, :uri => "example.com/") }.to \
      raise_error(HTTP::Request::UnsupportedSchemeError)
  end

  it "provides a #scheme accessor" do
    expect(request.scheme).to eq(:http)
  end

  it "provides a #verb accessor" do
    expect(subject.verb).to eq(:get)
  end

  it "sets given headers" do
    expect(subject["Accept"]).to eq("text/html")
  end

  describe "Host header" do
    subject { request["Host"] }

    context "was not given" do
      it { is_expected.to eq "example.com" }

      context "and request URI has non-standard port" do
        let(:request_uri) { "http://example.com:3000/" }
        it { is_expected.to eq "example.com:3000" }
      end
    end

    context "was explicitly given" do
      before { headers[:host] = "github.com" }
      it { is_expected.to eq "github.com" }
    end
  end

  describe "User-Agent header" do
    subject { request["User-Agent"] }

    context "was not given" do
      it { is_expected.to eq HTTP::Request::USER_AGENT }
    end

    context "was explicitly given" do
      before { headers[:user_agent] = "MrCrawly/123" }
      it { is_expected.to eq "MrCrawly/123" }
    end
  end

  describe "#redirect" do
    let(:headers)   { {:accept => "text/html"} }
    let(:proxy)     { {:proxy_username => "douglas", :proxy_password => "adams"} }
    let(:body)      { "The Ultimate Question" }

    let :request do
      HTTP::Request.new(
        :verb    => :post,
        :uri     => "http://example.com/",
        :headers => headers,
        :proxy   => proxy,
        :body    => body
      )
    end

    subject(:redirected) { request.redirect "http://blog.example.com/" }

    its(:uri)     { is_expected.to eq HTTP::URI.parse "http://blog.example.com/" }

    its(:verb)    { is_expected.to eq request.verb }
    its(:body)    { is_expected.to eq request.body }
    its(:proxy)   { is_expected.to eq request.proxy }

    it "presets new Host header" do
      expect(redirected["Host"]).to eq "blog.example.com"
    end

    context "with URL with non-standard port given" do
      subject(:redirected) { request.redirect "http://example.com:8080" }

      its(:uri)     { is_expected.to eq HTTP::URI.parse "http://example.com:8080" }

      its(:verb)    { is_expected.to eq request.verb }
      its(:body)    { is_expected.to eq request.body }
      its(:proxy)   { is_expected.to eq request.proxy }

      it "presets new Host header" do
        expect(redirected["Host"]).to eq "example.com:8080"
      end
    end

    context "with schema-less absolute URL given" do
      subject(:redirected) { request.redirect "//another.example.com/blog" }

      its(:uri)     { is_expected.to eq HTTP::URI.parse "http://another.example.com/blog" }

      its(:verb)    { is_expected.to eq request.verb }
      its(:body)    { is_expected.to eq request.body }
      its(:proxy)   { is_expected.to eq request.proxy }

      it "presets new Host header" do
        expect(redirected["Host"]).to eq "another.example.com"
      end
    end

    context "with relative URL given" do
      subject(:redirected) { request.redirect "/blog" }

      its(:uri)     { is_expected.to eq HTTP::URI.parse "http://example.com/blog" }

      its(:verb)    { is_expected.to eq request.verb }
      its(:body)    { is_expected.to eq request.body }
      its(:proxy)   { is_expected.to eq request.proxy }

      it "keeps Host header" do
        expect(redirected["Host"]).to eq "example.com"
      end

      context "with original URI having non-standard port" do
        let :request do
          HTTP::Request.new(
            :verb    => :post,
            :uri     => "http://example.com:8080/",
            :headers => headers,
            :proxy   => proxy,
            :body    => body
          )
        end

        its(:uri) { is_expected.to eq HTTP::URI.parse "http://example.com:8080/blog" }
      end
    end

    context "with relative URL that misses leading slash given" do
      subject(:redirected) { request.redirect "blog" }

      its(:uri)     { is_expected.to eq HTTP::URI.parse "http://example.com/blog" }

      its(:verb)    { is_expected.to eq request.verb }
      its(:body)    { is_expected.to eq request.body }
      its(:proxy)   { is_expected.to eq request.proxy }

      it "keeps Host header" do
        expect(redirected["Host"]).to eq "example.com"
      end

      context "with original URI having non-standard port" do
        let :request do
          HTTP::Request.new(
            :verb    => :post,
            :uri     => "http://example.com:8080/",
            :headers => headers,
            :proxy   => proxy,
            :body    => body
          )
        end

        its(:uri) { is_expected.to eq HTTP::URI.parse "http://example.com:8080/blog" }
      end
    end

    context "with new verb given" do
      subject { request.redirect "http://blog.example.com/", :get }
      its(:verb) { is_expected.to be :get }
    end
  end

  describe "#headline" do
    subject(:headline) { request.headline }

    it { is_expected.to eq "GET /foo?bar=baz HTTP/1.1" }

    context "when URI contains encoded query" do
      let(:encoded_query) { "t=1970-01-01T01%3A00%3A00%2B01%3A00" }
      let(:request_uri) { "http://example.com/foo/?#{encoded_query}" }

      it "does not unencodes query part" do
        expect(headline).to eq "GET /foo/?#{encoded_query} HTTP/1.1"
      end
    end

    context "when URI contains non-ASCII path" do
      let(:request_uri) { "http://example.com/キョ" }

      it "encodes non-ASCII path part" do
        expect(headline).to eq "GET /%E3%82%AD%E3%83%A7 HTTP/1.1"
      end
    end

    context "when URI contains fragment" do
      let(:request_uri) { "http://example.com/foo#bar" }

      it "omits fragment part" do
        expect(headline).to eq "GET /foo HTTP/1.1"
      end
    end

    context "with proxy" do
      let(:proxy) { {:user => "user", :pass => "pass"} }
      it { is_expected.to eq "GET http://example.com/foo?bar=baz HTTP/1.1" }

      context "and HTTPS uri" do
        let(:request_uri) { "https://example.com/foo?bar=baz" }

        it { is_expected.to eq "GET /foo?bar=baz HTTP/1.1" }
      end
    end
  end
end
