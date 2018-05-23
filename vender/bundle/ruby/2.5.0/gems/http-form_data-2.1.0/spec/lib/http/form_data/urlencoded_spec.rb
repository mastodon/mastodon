# frozen_string_literal: true
# coding: utf-8

RSpec.describe HTTP::FormData::Urlencoded do
  let(:data) { { "foo[bar]" => "test" } }
  subject(:form_data) { HTTP::FormData::Urlencoded.new data }

  describe "#content_type" do
    subject { form_data.content_type }
    it { is_expected.to eq "application/x-www-form-urlencoded" }
  end

  describe "#content_length" do
    subject { form_data.content_length }
    it { is_expected.to eq form_data.to_s.bytesize }

    context "with unicode chars" do
      let(:data) { { "foo[bar]" => "тест" } }
      it { is_expected.to eq form_data.to_s.bytesize }
    end
  end

  describe "#to_s" do
    subject { form_data.to_s }
    it { is_expected.to eq "foo%5Bbar%5D=test" }

    context "with unicode chars" do
      let(:data) { { "foo[bar]" => "тест" } }
      it { is_expected.to eq "foo%5Bbar%5D=%D1%82%D0%B5%D1%81%D1%82" }
    end

    it "rewinds content" do
      content = form_data.read
      expect(form_data.to_s).to eq content
      expect(form_data.read).to eq content
    end
  end

  describe "#size" do
    it "returns bytesize of multipart data" do
      expect(form_data.size).to eq form_data.to_s.bytesize
    end
  end

  describe "#read" do
    it "returns multipart data" do
      expect(form_data.read).to eq form_data.to_s
    end
  end

  describe "#rewind" do
    it "rewinds the multipart data IO" do
      form_data.read
      form_data.rewind
      expect(form_data.read).to eq form_data.to_s
    end
  end
end
