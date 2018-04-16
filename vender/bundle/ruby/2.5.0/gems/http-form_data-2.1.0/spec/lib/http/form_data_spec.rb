# frozen_string_literal: true

RSpec.describe HTTP::FormData do
  describe ".create" do
    subject { HTTP::FormData.create params }

    context "when form has no files" do
      let(:params) { { :foo => :bar } }
      it { is_expected.to be_a HTTP::FormData::Urlencoded }
    end

    context "when form has at least one file param" do
      let(:file) { HTTP::FormData::File.new(fixture("the-http-gem.info").to_s) }
      let(:params) { { :foo => :bar, :baz => file } }
      it { is_expected.to be_a HTTP::FormData::Multipart }
    end

    context "when form has file in an array param" do
      let(:file) { HTTP::FormData::File.new(fixture("the-http-gem.info").to_s) }
      let(:params) { { :foo => :bar, :baz => [file] } }
      it { is_expected.to be_a HTTP::FormData::Multipart }
    end
  end

  describe ".ensure_hash" do
    subject(:ensure_hash) { HTTP::FormData.ensure_hash data }

    context "when Hash given" do
      let(:data) { { :foo => :bar } }
      it { is_expected.to eq :foo => :bar }
    end

    context "when #to_h given" do
      let(:data) { double(:to_h => { :foo => :bar }) }
      it { is_expected.to eq :foo => :bar }
    end

    context "when nil given" do
      let(:data) { nil }
      it { is_expected.to eq({}) }
    end

    context "when neither Hash nor #to_h given" do
      let(:data) { double }
      it "fails with HTTP::FormData::Error" do
        expect { ensure_hash }.to raise_error HTTP::FormData::Error
      end
    end
  end
end
