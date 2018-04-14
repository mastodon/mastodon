# frozen_string_literal: true

RSpec.describe HTTP::ContentType do
  describe ".parse" do
    context "with text/plain" do
      subject { described_class.parse "text/plain" }
      its(:mime_type) { is_expected.to eq "text/plain" }
      its(:charset)   { is_expected.to be_nil }
    end

    context "with tEXT/plaIN" do
      subject { described_class.parse "tEXT/plaIN" }
      its(:mime_type) { is_expected.to eq "text/plain" }
      its(:charset)   { is_expected.to be_nil }
    end

    context "with text/plain; charset=utf-8" do
      subject { described_class.parse "text/plain; charset=utf-8" }
      its(:mime_type) { is_expected.to eq "text/plain" }
      its(:charset)   { is_expected.to eq "utf-8" }
    end

    context 'with text/plain; charset="utf-8"' do
      subject { described_class.parse 'text/plain; charset="utf-8"' }
      its(:mime_type) { is_expected.to eq "text/plain" }
      its(:charset)   { is_expected.to eq "utf-8" }
    end

    context "with text/plain; charSET=utf-8" do
      subject { described_class.parse "text/plain; charSET=utf-8" }
      its(:mime_type) { is_expected.to eq "text/plain" }
      its(:charset)   { is_expected.to eq "utf-8" }
    end

    context "with text/plain; foo=bar; charset=utf-8" do
      subject { described_class.parse "text/plain; foo=bar; charset=utf-8" }
      its(:mime_type) { is_expected.to eq "text/plain" }
      its(:charset)   { is_expected.to eq "utf-8" }
    end

    context "with text/plain;charset=utf-8;foo=bar" do
      subject { described_class.parse "text/plain;charset=utf-8;foo=bar" }
      its(:mime_type) { is_expected.to eq "text/plain" }
      its(:charset)   { is_expected.to eq "utf-8" }
    end
  end
end
