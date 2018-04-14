# frozen_string_literal: true
# coding: utf-8

RSpec.describe HTTP::FormData::File do
  let(:opts)      { nil }
  let(:form_file) { described_class.new(file, opts) }

  describe "#size" do
    subject { form_file.size }

    context "when file given as a String" do
      let(:file) { fixture("the-http-gem.info").to_s }
      it { is_expected.to eq fixture("the-http-gem.info").size }
    end

    context "when file given as a Pathname" do
      let(:file) { fixture("the-http-gem.info") }
      it { is_expected.to eq fixture("the-http-gem.info").size }
    end

    context "when file given as File" do
      let(:file) { fixture("the-http-gem.info").open }
      after { file.close }
      it { is_expected.to eq fixture("the-http-gem.info").size }
    end

    context "when file given as IO" do
      let(:file) { StringIO.new "привет мир!" }
      it { is_expected.to eq 20 }
    end
  end

  describe "#to_s" do
    subject { form_file.to_s }

    context "when file given as a String" do
      let(:file) { fixture("the-http-gem.info").to_s }
      it { is_expected.to eq fixture("the-http-gem.info").read(:mode => "rb") }

      it "rewinds content" do
        content = form_file.read
        expect(form_file.to_s).to eq content
        expect(form_file.read).to eq content
      end
    end

    context "when file given as a Pathname" do
      let(:file) { fixture("the-http-gem.info") }
      it { is_expected.to eq fixture("the-http-gem.info").read(:mode => "rb") }

      it "rewinds content" do
        content = form_file.read
        expect(form_file.to_s).to eq content
        expect(form_file.read).to eq content
      end
    end

    context "when file given as File" do
      let(:file) { fixture("the-http-gem.info").open("rb") }
      after { file.close }
      it { is_expected.to eq fixture("the-http-gem.info").read(:mode => "rb") }

      it "rewinds content" do
        content = form_file.read
        expect(form_file.to_s).to eq content
        expect(form_file.read).to eq content
      end
    end

    context "when file given as IO" do
      let(:file) { StringIO.new "привет мир!" }
      it { is_expected.to eq "привет мир!" }

      it "rewinds content" do
        content = form_file.read
        expect(form_file.to_s).to eq content
        expect(form_file.read).to eq content
      end
    end
  end

  describe "#read" do
    subject { form_file.read }

    context "when file given as a String" do
      let(:file) { fixture("the-http-gem.info").to_s }
      it { is_expected.to eq fixture("the-http-gem.info").read(:mode => "rb") }
    end

    context "when file given as a Pathname" do
      let(:file) { fixture("the-http-gem.info") }
      it { is_expected.to eq fixture("the-http-gem.info").read(:mode => "rb") }
    end

    context "when file given as File" do
      let(:file) { fixture("the-http-gem.info").open("rb") }
      after { file.close }
      it { is_expected.to eq fixture("the-http-gem.info").read(:mode => "rb") }
    end

    context "when file given as IO" do
      let(:file) { StringIO.new "привет мир!" }
      it { is_expected.to eq "привет мир!" }
    end
  end

  describe "#rewind" do
    context "when file given as a String" do
      let(:file) { fixture("the-http-gem.info").to_s }

      it "rewinds the underlying IO object" do
        content = form_file.read
        form_file.rewind
        expect(form_file.read).to eq content
      end
    end

    context "when file given as a Pathname" do
      let(:file) { fixture("the-http-gem.info") }

      it "rewinds the underlying IO object" do
        content = form_file.read
        form_file.rewind
        expect(form_file.read).to eq content
      end
    end

    context "when file given as File" do
      let(:file) { fixture("the-http-gem.info").open("rb") }
      after { file.close }

      it "rewinds the underlying IO object" do
        content = form_file.read
        form_file.rewind
        expect(form_file.read).to eq content
      end
    end

    context "when file given as IO" do
      let(:file) { StringIO.new "привет мир!" }

      it "rewinds the underlying IO object" do
        content = form_file.read
        form_file.rewind
        expect(form_file.read).to eq content
      end
    end
  end

  describe "#filename" do
    subject { form_file.filename }

    context "when file given as a String" do
      let(:file) { fixture("the-http-gem.info").to_s }

      it { is_expected.to eq ::File.basename file }

      context "and filename given with options" do
        let(:opts) { { :filename => "foobar.txt" } }
        it { is_expected.to eq "foobar.txt" }
      end
    end

    context "when file given as a Pathname" do
      let(:file) { fixture("the-http-gem.info") }

      it { is_expected.to eq ::File.basename file }

      context "and filename given with options" do
        let(:opts) { { :filename => "foobar.txt" } }
        it { is_expected.to eq "foobar.txt" }
      end
    end

    context "when file given as File" do
      let(:file) { fixture("the-http-gem.info").open }
      after { file.close }

      it { is_expected.to eq "the-http-gem.info" }

      context "and filename given with options" do
        let(:opts) { { :filename => "foobar.txt" } }
        it { is_expected.to eq "foobar.txt" }
      end
    end

    context "when file given as IO" do
      let(:file) { StringIO.new }

      it { is_expected.to eq "stream-#{file.object_id}" }

      context "and filename given with options" do
        let(:opts) { { :filename => "foobar.txt" } }
        it { is_expected.to eq "foobar.txt" }
      end
    end
  end

  describe "#content_type" do
    let(:file) { StringIO.new }
    subject    { form_file.content_type }

    it { is_expected.to eq "application/octet-stream" }

    context "when it was given with options" do
      let(:opts) { { :content_type => "application/json" } }
      it { is_expected.to eq "application/json" }
    end
  end

  describe "#mime_type" do
    it "should be an alias of #content_type" do
      expect(described_class.instance_method(:mime_type))
        .to eq(described_class.instance_method(:content_type))
    end
  end
end
