require 'spec_helper'

describe Paperclip::FileCommandContentTypeDetector do
  it 'returns a content type based on the content of the file' do
    tempfile = Tempfile.new("something")
    tempfile.write("This is a file.")
    tempfile.rewind

    assert_equal "text/plain", Paperclip::FileCommandContentTypeDetector.new(tempfile.path).detect

    tempfile.close
  end

  it 'returns a sensible default when the file command is missing' do
    Paperclip.stubs(:run).raises(Terrapin::CommandLineError.new)
    @filename = "/path/to/something"
    assert_equal "application/octet-stream",
      Paperclip::FileCommandContentTypeDetector.new(@filename).detect
  end

  it 'returns a sensible default on the odd chance that run returns nil' do
    Paperclip.stubs(:run).returns(nil)
    assert_equal "application/octet-stream",
      Paperclip::FileCommandContentTypeDetector.new("windows").detect
  end

  context "#type_from_file_command" do
    let(:detector) { Paperclip::FileCommandContentTypeDetector.new("html") }

    it "does work with the output of old versions of file" do
      Paperclip.stubs(:run).returns("text/html charset=us-ascii")
      expect(detector.detect).to eq("text/html")
    end

    it "does work with the output of new versions of file" do
      Paperclip.stubs(:run).returns("text/html; charset=us-ascii")
      expect(detector.detect).to eq("text/html")
    end
  end
end
