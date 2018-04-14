# frozen_string_literal: true
# coding: utf-8

RSpec.describe HTTP::Request::Writer do
  let(:io)          { StringIO.new }
  let(:body)        { HTTP::Request::Body.new("") }
  let(:headers)     { HTTP::Headers.new }
  let(:headerstart) { "GET /test HTTP/1.1" }

  subject(:writer)  { described_class.new(io, body, headers, headerstart) }

  describe "#stream" do
    context "when multiple headers are set" do
      let(:headers) { HTTP::Headers.coerce "Host" => "example.org" }

      it "separates headers with carriage return and line feed" do
        writer.stream
        expect(io.string).to eq [
          "#{headerstart}\r\n",
          "Host: example.org\r\nContent-Length: 0\r\n\r\n"
        ].join
      end
    end

    context "when body is nonempty" do
      let(:body) { HTTP::Request::Body.new("content") }

      it "writes it to the socket and sets Content-Length" do
        writer.stream
        expect(io.string).to eq [
          "#{headerstart}\r\n",
          "Content-Length: 7\r\n\r\n",
          "content"
        ].join
      end
    end

    context "when body is empty" do
      let(:body) { HTTP::Request::Body.new(nil) }

      it "doesn't write anything to the socket and sets Content-Length" do
        writer.stream
        expect(io.string).to eq [
          "#{headerstart}\r\n",
          "Content-Length: 0\r\n\r\n"
        ].join
      end
    end

    context "when Content-Length header is set" do
      let(:headers) { HTTP::Headers.coerce "Content-Length" => "12" }
      let(:body)    { HTTP::Request::Body.new("content") }

      it "keeps the given value" do
        writer.stream
        expect(io.string).to eq [
          "#{headerstart}\r\n",
          "Content-Length: 12\r\n\r\n",
          "content"
        ].join
      end
    end

    context "when Transfer-Encoding is chunked" do
      let(:headers) { HTTP::Headers.coerce "Transfer-Encoding" => "chunked" }
      let(:body)    { HTTP::Request::Body.new(%w[request body]) }

      it "writes encoded content and omits Content-Length" do
        writer.stream
        expect(io.string).to eq [
          "#{headerstart}\r\n",
          "Transfer-Encoding: chunked\r\n\r\n",
          "7\r\nrequest\r\n4\r\nbody\r\n0\r\n\r\n"
        ].join
      end
    end
  end
end
