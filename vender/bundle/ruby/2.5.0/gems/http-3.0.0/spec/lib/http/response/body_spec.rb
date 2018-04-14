# frozen_string_literal: true

RSpec.describe HTTP::Response::Body do
  let(:connection) { double(:sequence_id => 0) }
  let(:chunks)     { [String.new("Hello, "), String.new("World!")] }

  before do
    allow(connection).to receive(:readpartial) { chunks.shift }
    allow(connection).to receive(:body_completed?) { chunks.empty? }
  end

  subject(:body) { described_class.new(connection, :encoding => Encoding::UTF_8) }

  it "streams bodies from responses" do
    expect(subject.to_s).to eq("Hello, World!")
  end

  context "when body empty" do
    let(:chunks) { [String.new("")] }

    it "returns responds to empty? with true" do
      expect(subject).to be_empty
    end
  end

  describe "#readpartial" do
    context "with size given" do
      it "passes value to underlying connection" do
        expect(connection).to receive(:readpartial).with(42)
        body.readpartial 42
      end
    end

    context "without size given" do
      it "does not blows up" do
        expect { body.readpartial }.to_not raise_error
      end

      it "calls underlying connection readpartial without specific size" do
        expect(connection).to receive(:readpartial).with no_args
        body.readpartial
      end
    end

    it "returns content in specified encoding" do
      body = described_class.new(connection)
      expect(connection).to receive(:readpartial).
        and_return(String.new("content").force_encoding(Encoding::UTF_8))
      expect(body.readpartial.encoding).to eq Encoding::BINARY

      body = described_class.new(connection, :encoding => Encoding::UTF_8)
      expect(connection).to receive(:readpartial).
        and_return(String.new("content").force_encoding(Encoding::BINARY))
      expect(body.readpartial.encoding).to eq Encoding::UTF_8
    end
  end

  context "when body is gzipped" do
    let(:chunks) do
      body = Zlib::Deflate.deflate("Hi, HTTP here ☺")
      len  = body.length
      [String.new(body[0, len / 2]), String.new(body[(len / 2)..-1])]
    end
    subject(:body) do
      inflater = HTTP::Response::Inflater.new(connection)
      described_class.new(inflater, :encoding => Encoding::UTF_8)
    end

    it "decodes body" do
      expect(subject.to_s).to eq("Hi, HTTP here ☺")
    end

    describe "#readpartial" do
      it "streams decoded body" do
        [
          "Hi, HTTP ",
          "here ☺",
          nil
        ].each do |part|
          expect(subject.readpartial).to eq(part)
        end
      end
    end
  end
end
