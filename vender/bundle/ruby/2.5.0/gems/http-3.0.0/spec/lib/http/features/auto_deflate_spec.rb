# frozen_string_literal: true

RSpec.describe HTTP::Features::AutoDeflate do
  subject { HTTP::Features::AutoDeflate.new }

  it "raises error for wrong type" do
    expect { HTTP::Features::AutoDeflate.new(:method => :wrong) }.
      to raise_error(HTTP::Error) { |error|
        expect(error.message).to eq("Only gzip and deflate methods are supported")
      }
  end

  it "accepts gzip method" do
    expect(HTTP::Features::AutoDeflate.new(:method => :gzip).method).to eq "gzip"
  end

  it "accepts deflate method" do
    expect(HTTP::Features::AutoDeflate.new(:method => :deflate).method).to eq "deflate"
  end

  it "accepts string as method" do
    expect(HTTP::Features::AutoDeflate.new(:method => "gzip").method).to eq "gzip"
  end

  it "uses gzip by default" do
    expect(subject.method).to eq("gzip")
  end

  describe "#deflated_body" do
    let(:body)          { %w[bees cows] }
    let(:deflated_body) { subject.deflated_body(body) }

    context "when method is gzip" do
      subject { HTTP::Features::AutoDeflate.new(:method => :gzip) }

      it "returns object which yields gzipped content of the given body" do
        io = StringIO.new
        io.set_encoding(Encoding::BINARY)
        gzip = Zlib::GzipWriter.new(io)
        gzip.write("beescows")
        gzip.close
        gzipped = io.string

        expect(deflated_body.each.to_a.join).to eq gzipped
      end

      it "caches compressed content when size is called" do
        io = StringIO.new
        io.set_encoding(Encoding::BINARY)
        gzip = Zlib::GzipWriter.new(io)
        gzip.write("beescows")
        gzip.close
        gzipped = io.string

        expect(deflated_body.size).to eq gzipped.bytesize
        expect(deflated_body.each.to_a.join).to eq gzipped
      end
    end

    context "when method is deflate" do
      subject { HTTP::Features::AutoDeflate.new(:method => :deflate) }

      it "returns object which yields deflated content of the given body" do
        deflated = Zlib::Deflate.deflate("beescows")

        expect(deflated_body.each.to_a.join).to eq deflated
      end

      it "caches compressed content when size is called" do
        deflated = Zlib::Deflate.deflate("beescows")

        expect(deflated_body.size).to eq deflated.bytesize
        expect(deflated_body.each.to_a.join).to eq deflated
      end
    end
  end
end
