# frozen_string_literal: true

RSpec.describe HTTP::FormData::Part do
  let(:body)     { "" }
  let(:opts)     { {} }
  subject(:part) { HTTP::FormData::Part.new(body, opts) }

  describe "#size" do
    subject { part.size }

    context "when body given as a String" do
      let(:body) { "привет мир!" }
      it { is_expected.to eq 20 }
    end
  end

  describe "#to_s" do
    subject! { part.to_s }

    context "when body given as String" do
      let(:body) { "привет мир!" }
      it { is_expected.to eq "привет мир!" }

      it "rewinds content" do
        content = part.read
        expect(part.to_s).to eq content
        expect(part.read).to eq content
      end
    end
  end

  describe "#read" do
    subject { part.read }

    context "when body given as String" do
      let(:body) { "привет мир!" }
      it { is_expected.to eq "привет мир!" }
    end
  end

  describe "#rewind" do
    context "when body given as String" do
      let(:body) { "привет мир!" }

      it "rewinds the underlying IO object" do
        part.read
        part.rewind
        expect(part.read).to eq "привет мир!"
      end
    end
  end

  describe "#filename" do
    subject { part.filename }

    it { is_expected.to eq nil }

    context "when it was given with options" do
      let(:opts) { { :filename => "foobar.txt" } }
      it { is_expected.to eq "foobar.txt" }
    end
  end

  describe "#content_type" do
    subject { part.content_type }

    it { is_expected.to eq nil }

    context "when it was given with options" do
      let(:opts) { { :content_type => "application/json" } }
      it { is_expected.to eq "application/json" }
    end
  end
end
