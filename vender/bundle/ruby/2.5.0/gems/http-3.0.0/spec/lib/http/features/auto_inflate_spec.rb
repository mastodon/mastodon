# frozen_string_literal: true

RSpec.describe HTTP::Features::AutoInflate do
  subject { HTTP::Features::AutoInflate.new }
  let(:connection) { double }
  let(:headers) { {} }
  let(:response) do
    HTTP::Response.new(
      :version    => "1.1",
      :status     => 200,
      :headers    => headers,
      :connection => connection
    )
  end

  describe "stream_for" do
    context "when there is no Content-Encoding header" do
      it "returns connection" do
        stream = subject.stream_for(connection, response)
        expect(stream).to eq(connection)
      end
    end

    context "for identity Content-Encoding header" do
      let(:headers) { {:content_encoding => "not-supported"} }

      it "returns connection" do
        stream = subject.stream_for(connection, response)
        expect(stream).to eq(connection)
      end
    end

    context "for unknown Content-Encoding header" do
      let(:headers) { {:content_encoding => "not-supported"} }

      it "returns connection" do
        stream = subject.stream_for(connection, response)
        expect(stream).to eq(connection)
      end
    end

    context "for deflate Content-Encoding header" do
      let(:headers) { {:content_encoding => "deflate"} }

      it "returns HTTP::Response::Inflater instance - connection wrapper" do
        stream = subject.stream_for(connection, response)
        expect(stream).to be_instance_of HTTP::Response::Inflater
      end
    end

    context "for gzip Content-Encoding header" do
      let(:headers) { {:content_encoding => "gzip"} }

      it "returns HTTP::Response::Inflater instance - connection wrapper" do
        stream = subject.stream_for(connection, response)
        expect(stream).to be_instance_of HTTP::Response::Inflater
      end
    end

    context "for x-gzip Content-Encoding header" do
      let(:headers) { {:content_encoding => "x-gzip"} }

      it "returns HTTP::Response::Inflater instance - connection wrapper" do
        stream = subject.stream_for(connection, response)
        expect(stream).to be_instance_of HTTP::Response::Inflater
      end
    end
  end
end
