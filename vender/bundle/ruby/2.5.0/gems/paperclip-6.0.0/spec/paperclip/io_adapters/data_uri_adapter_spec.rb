require 'spec_helper'

describe Paperclip::DataUriAdapter do
  before do
    Paperclip::DataUriAdapter.register
  end

  after do
    Paperclip.io_adapters.unregister(described_class)

    if @subject
      @subject.close
    end
  end

  it 'allows a missing mime-type' do
    adapter = Paperclip.io_adapters.for("data:;base64,#{original_base64_content}")
    assert_equal Paperclip::DataUriAdapter, adapter.class
  end

  it 'alows mime type that has dot in it' do
    adapter = Paperclip.io_adapters.for("data:image/vnd.microsoft.icon;base64,#{original_base64_content}")
    assert_equal Paperclip::DataUriAdapter, adapter.class
  end

  context "a new instance" do
    before do
      @contents = "data:image/png;base64,#{original_base64_content}"
      @subject = Paperclip.io_adapters.for(@contents, hash_digest: Digest::MD5)
    end

    it "returns a nondescript file name" do
      assert_equal "data", @subject.original_filename
    end

    it "returns a content type" do
      assert_equal "image/png", @subject.content_type
    end

    it "returns the size of the data" do
      assert_equal 4456, @subject.size
    end

    it "generates a correct MD5 hash of the contents" do
      assert_equal(
        Digest::MD5.hexdigest(Base64.decode64(original_base64_content)),
        @subject.fingerprint
      )
    end

    it "generates correct fingerprint after read" do
      fingerprint = Digest::MD5.hexdigest(@subject.read)
      assert_equal fingerprint, @subject.fingerprint
    end

    it "generates same fingerprint" do
      assert_equal @subject.fingerprint, @subject.fingerprint
    end

    it 'accepts a content_type' do
      @subject.content_type = 'image/png'
      assert_equal 'image/png', @subject.content_type
    end

    it 'accepts an original_filename' do
      @subject.original_filename = 'image.png'
      assert_equal 'image.png', @subject.original_filename
    end

    it "does not generate filenames that include restricted characters" do
      @subject.original_filename = 'image:restricted.png'
      assert_equal 'image_restricted.png', @subject.original_filename
    end

    it "does not generate paths that include restricted characters" do
      @subject.original_filename = 'image:restricted.png'
      expect(@subject.path).to_not match(/:/)
    end

  end

  def original_base64_content
    Base64.encode64(original_file_contents)
  end

  def original_file_contents
    @original_file_contents ||= File.read(fixture_file('5k.png'))
  end
end
