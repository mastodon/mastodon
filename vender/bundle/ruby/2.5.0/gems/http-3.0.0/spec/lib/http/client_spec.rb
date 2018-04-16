# frozen_string_literal: true
# coding: utf-8

require "support/http_handling_shared"
require "support/dummy_server"
require "support/ssl_helper"

RSpec.describe HTTP::Client do
  run_server(:dummy) { DummyServer.new }

  StubbedClient = Class.new(HTTP::Client) do
    def perform(request, options)
      stubs.fetch(request.uri) { super(request, options) }
    end

    def stubs
      @stubs ||= {}
    end

    def stub(stubs)
      @stubs = stubs.each_with_object({}) do |(k, v), o|
        o[HTTP::URI.parse k] = v
      end

      self
    end
  end

  def redirect_response(location, status = 302)
    HTTP::Response.new(
      :status  => status,
      :version => "1.1",
      :headers => {"Location" => location},
      :body    => ""
    )
  end

  def simple_response(body, status = 200)
    HTTP::Response.new(
      :status  => status,
      :version => "1.1",
      :body    => body
    )
  end

  describe "following redirects" do
    it "returns response of new location" do
      client = StubbedClient.new(:follow => true).stub(
        "http://example.com/"     => redirect_response("http://example.com/blog"),
        "http://example.com/blog" => simple_response("OK")
      )

      expect(client.get("http://example.com/").to_s).to eq "OK"
    end

    it "prepends previous request uri scheme and host if needed" do
      client = StubbedClient.new(:follow => true).stub(
        "http://example.com/"           => redirect_response("/index"),
        "http://example.com/index"      => redirect_response("/index.html"),
        "http://example.com/index.html" => simple_response("OK")
      )

      expect(client.get("http://example.com/").to_s).to eq "OK"
    end

    it "fails upon endless redirects" do
      client = StubbedClient.new(:follow => true).stub(
        "http://example.com/" => redirect_response("/")
      )

      expect { client.get("http://example.com/") }.
        to raise_error(HTTP::Redirector::EndlessRedirectError)
    end

    it "fails if max amount of hops reached" do
      client = StubbedClient.new(:follow => {:max_hops => 5}).stub(
        "http://example.com/"  => redirect_response("/1"),
        "http://example.com/1" => redirect_response("/2"),
        "http://example.com/2" => redirect_response("/3"),
        "http://example.com/3" => redirect_response("/4"),
        "http://example.com/4" => redirect_response("/5"),
        "http://example.com/5" => redirect_response("/6"),
        "http://example.com/6" => simple_response("OK")
      )

      expect { client.get("http://example.com/") }.
        to raise_error(HTTP::Redirector::TooManyRedirectsError)
    end

    context "with non-ASCII URLs" do
      it "theoretically works like a charm" do
        client = StubbedClient.new(:follow => true).stub(
          "http://example.com/"      => redirect_response("/könig"),
          "http://example.com/könig" => simple_response("OK")
        )

        expect { client.get "http://example.com/könig" }.not_to raise_error
      end

      it "works like a charm in real world" do
        url    = "http://git.io/jNeY"
        client = HTTP.follow
        expect(client.get(url).to_s).to include "support for non-ascii URIs"
      end
    end
  end

  describe "parsing params" do
    let(:client) { HTTP::Client.new }
    before { allow(client).to receive :perform }

    it "accepts params within the provided URL" do
      expect(HTTP::Request).to receive(:new) do |opts|
        expect(CGI.parse(opts[:uri].query)).to eq("foo" => %w[bar])
      end

      client.get("http://example.com/?foo=bar")
    end

    it "combines GET params from the URI with the passed in params" do
      expect(HTTP::Request).to receive(:new) do |opts|
        expect(CGI.parse(opts[:uri].query)).to eq("foo" => %w[bar], "baz" => %w[quux])
      end

      client.get("http://example.com/?foo=bar", :params => {:baz => "quux"})
    end

    it "merges duplicate values" do
      expect(HTTP::Request).to receive(:new) do |opts|
        expect(opts[:uri].query).to match(/^(a=1&a=2|a=2&a=1)$/)
      end

      client.get("http://example.com/?a=1", :params => {:a => 2})
    end

    it "does not modifies query part if no params were given" do
      expect(HTTP::Request).to receive(:new) do |opts|
        expect(opts[:uri].query).to eq "deadbeef"
      end

      client.get("http://example.com/?deadbeef")
    end

    it "does not corrupts index-less arrays" do
      expect(HTTP::Request).to receive(:new) do |opts|
        expect(CGI.parse(opts[:uri].query)).to eq "a[]" => %w[b c], "d" => %w[e]
      end

      client.get("http://example.com/?a[]=b&a[]=c", :params => {:d => "e"})
    end

    it "properly encodes colons" do
      expect(HTTP::Request).to receive(:new) do |opts|
        expect(opts[:uri].query).to eq "t=1970-01-01T00%3A00%3A00Z"
      end

      client.get("http://example.com/", :params => {:t => "1970-01-01T00:00:00Z"})
    end
  end

  describe "passing multipart form data" do
    it "creates url encoded form data object" do
      client = HTTP::Client.new
      allow(client).to receive(:perform)

      expect(HTTP::Request).to receive(:new) do |opts|
        expect(opts[:body]).to be_a(HTTP::FormData::Urlencoded)
        expect(opts[:body].to_s).to eq "foo=bar"
      end

      client.get("http://example.com/", :form => {:foo => "bar"})
    end

    it "creates multipart form data object" do
      client = HTTP::Client.new
      allow(client).to receive(:perform)

      expect(HTTP::Request).to receive(:new) do |opts|
        expect(opts[:body]).to be_a(HTTP::FormData::Multipart)
        expect(opts[:body].to_s).to include("content")
      end

      client.get("http://example.com/", :form => {:foo => HTTP::FormData::Part.new("content")})
    end
  end

  describe "passing json" do
    it "encodes given object" do
      client = HTTP::Client.new
      allow(client).to receive(:perform)

      expect(HTTP::Request).to receive(:new) do |opts|
        expect(opts[:body]).to eq '{"foo":"bar"}'
      end

      client.get("http://example.com/", :json => {:foo => :bar})
    end
  end

  describe "#request" do
    context "with non-ASCII URLs" do
      it "theoretically works like a charm" do
        client = described_class.new
        expect { client.get "#{dummy.endpoint}/könig" }.not_to raise_error
      end

      it "works like a charm in real world" do
        url     = "https://github.com/httprb/http.rb/pull/197/ö無"
        client  = HTTP.follow
        expect(client.get(url).to_s).to include "support for non-ascii URIs"
      end
    end

    context "with explicitly given `Host` header" do
      let(:headers) { {"Host" => "another.example.com"} }
      let(:client)  { described_class.new :headers => headers }

      it "keeps `Host` header as is" do
        expect(client).to receive(:perform) do |req, _|
          expect(req["Host"]).to eq "another.example.com"
        end

        client.request(:get, "http://example.com/")
      end
    end

    context "when :auto_deflate was specified" do
      let(:headers) { {"Content-Length" => "12"} }
      let(:client)  { described_class.new :headers => headers, :features => {:auto_deflate => {}} }

      it "deletes Content-Length header" do
        expect(client).to receive(:perform) do |req, _|
          expect(req["Content-Length"]).to eq nil
        end

        client.request(:get, "http://example.com/")
      end

      it "sets Content-Encoding header" do
        expect(client).to receive(:perform) do |req, _|
          expect(req["Content-Encoding"]).to eq "gzip"
        end

        client.request(:get, "http://example.com/")
      end
    end
  end

  include_context "HTTP handling" do
    let(:extra_options) { {} }
    let(:options) { {} }
    let(:server)  { dummy }
    let(:client)  { described_class.new(options.merge(extra_options)) }
  end

  describe "working with SSL" do
    run_server(:dummy_ssl) { DummyServer.new(:ssl => true) }

    let(:extra_options) { {} }

    let(:client) do
      described_class.new options.merge(:ssl_context => SSLHelper.client_context).merge(extra_options)
    end

    include_context "HTTP handling" do
      let(:server) { dummy_ssl }
    end

    it "just works" do
      response = client.get(dummy_ssl.endpoint)
      expect(response.body.to_s).to eq("<!doctype html>")
    end

    it "fails with OpenSSL::SSL::SSLError if host mismatch" do
      expect { client.get(dummy_ssl.endpoint.gsub("127.0.0.1", "localhost")) }.
        to raise_error(OpenSSL::SSL::SSLError, /does not match/)
    end

    context "with SSL options instead of a context" do
      let(:client) do
        described_class.new options.merge :ssl => SSLHelper.client_params
      end

      it "just works" do
        response = client.get(dummy_ssl.endpoint)
        expect(response.body.to_s).to eq("<!doctype html>")
      end
    end
  end

  describe "#perform" do
    let(:client) { described_class.new }

    it "calls finish_response once body was fully flushed" do
      expect_any_instance_of(HTTP::Connection).to receive(:finish_response).and_call_original
      client.get(dummy.endpoint).to_s
    end

    context "with HEAD request" do
      it "does not iterates through body" do
        expect_any_instance_of(HTTP::Connection).to_not receive(:readpartial)
        client.head(dummy.endpoint)
      end

      it "finishes response after headers were received" do
        expect_any_instance_of(HTTP::Connection).to receive(:finish_response).and_call_original
        client.head(dummy.endpoint)
      end
    end

    context "when server fully flushes response in one chunk" do
      before do
        socket_spy = double

        chunks = [
          <<-RESPONSE.gsub(/^\s*\| */, "").gsub(/\n/, "\r\n")
          | HTTP/1.1 200 OK
          | Content-Type: text/html
          | Server: WEBrick/1.3.1 (Ruby/1.9.3/2013-11-22)
          | Date: Mon, 24 Mar 2014 00:32:22 GMT
          | Content-Length: 15
          | Connection: Keep-Alive
          |
          | <!doctype html>
          RESPONSE
        ]

        allow(socket_spy).to receive(:close) { nil }
        allow(socket_spy).to receive(:closed?) { true }
        allow(socket_spy).to receive(:readpartial) { chunks.shift || :eof }
        allow(socket_spy).to receive(:write) { chunks[0].length }

        allow(TCPSocket).to receive(:open) { socket_spy }
      end

      it "properly reads body" do
        body = client.get(dummy.endpoint).to_s
        expect(body).to eq "<!doctype html>"
      end
    end

    context "when uses chunked transfer encoding" do
      let(:chunks) do
        [
          <<-RESPONSE.gsub(/^\s*\| */, "").gsub(/\n/, "\r\n") << body
          | HTTP/1.1 200 OK
          | Content-Type: application/json
          | Transfer-Encoding: chunked
          | Connection: close
          |
          RESPONSE
        ]
      end
      let(:body) do
        <<-BODY.gsub(/^\s*\| */, "").gsub(/\n/, "\r\n")
        | 9
        | {"state":
        | 5
        | "ok"}
        | 0
        |
        BODY
      end

      before do
        socket_spy = double

        allow(socket_spy).to receive(:close) { nil }
        allow(socket_spy).to receive(:closed?) { true }
        allow(socket_spy).to receive(:readpartial) { chunks.shift || :eof }
        allow(socket_spy).to receive(:write) { chunks[0].length }

        allow(TCPSocket).to receive(:open) { socket_spy }
      end

      it "properly reads body" do
        body = client.get(dummy.endpoint).to_s
        expect(body).to eq '{"state":"ok"}'
      end

      context "with broken body (too early closed connection)" do
        let(:body) do
          <<-BODY.gsub(/^\s*\| */, "").gsub(/\n/, "\r\n")
          | 9
          | {"state":
          BODY
        end

        it "raises HTTP::ConnectionError" do
          expect { client.get(dummy.endpoint).to_s }.to raise_error(HTTP::ConnectionError)
        end
      end
    end
  end
end
