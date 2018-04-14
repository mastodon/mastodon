require "spec_helper"

describe Paperclip::Tempfile do
  context "A Paperclip Tempfile" do
    before do
      @tempfile = described_class.new(["file", ".jpg"])
    end

    after { @tempfile.close }

    it "has its path contain a real extension" do
      assert_equal ".jpg", File.extname(@tempfile.path)
    end

    it "is a real Tempfile" do
      assert @tempfile.is_a?(::Tempfile)
    end
  end

  context "Another Paperclip Tempfile" do
    before do
      @tempfile = described_class.new("file")
    end

    after { @tempfile.close }

    it "does not have an extension if not given one" do
      assert_equal "", File.extname(@tempfile.path)
    end

    it "is a real Tempfile" do
      assert @tempfile.is_a?(::Tempfile)
    end
  end
end
