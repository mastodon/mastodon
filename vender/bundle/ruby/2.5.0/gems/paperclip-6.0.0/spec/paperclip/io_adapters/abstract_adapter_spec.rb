require 'spec_helper'

describe Paperclip::AbstractAdapter do
  class TestAdapter < Paperclip::AbstractAdapter
    attr_accessor :tempfile

    def content_type
      Paperclip::ContentTypeDetector.new(path).detect
    end
  end

  subject { TestAdapter.new(nil) }

  context "content type from file contents" do
    before do
      subject.stubs(:path).returns("image.png")
      Paperclip.stubs(:run).returns("image/png\n")
      Paperclip::ContentTypeDetector.any_instance.stubs(:type_from_mime_magic).returns("image/png")
    end

    it "returns the content type without newline" do
      assert_equal "image/png", subject.content_type
    end
  end

  context "nil?" do
    it "returns false" do
      assert !subject.nil?
    end
  end

  context "delegation" do
    before do
      subject.tempfile = stub("Tempfile")
    end

    [:binmode, :binmode?, :close, :close!, :closed?, :eof?, :path, :readbyte, :rewind, :unlink].each do |method|
      it "delegates #{method} to @tempfile" do
        subject.tempfile.stubs(method)
        subject.public_send(method)
        assert_received subject.tempfile, method
      end
    end
  end

  it 'gets rid of slashes and colons in filenames' do
    subject.original_filename = "awesome/file:name.png"

    assert_equal "awesome_file_name.png", subject.original_filename
  end

  it 'is an assignment' do
    assert subject.assignment?
  end

  it 'is not nil' do
    assert !subject.nil?
  end

  it "generates a destination filename with no original filename" do
    expect(subject.send(:destination).path).to_not be_nil
  end

  it 'uses the original filename to generate the tempfile' do
    subject.original_filename = "file.png"
    expect(subject.send(:destination).path).to end_with(".png")
  end

  context "generates a fingerprint" do
    subject { TestAdapter.new(nil, options) }

    before do
      subject.stubs(:path).returns(fixture_file("50x50.png"))
    end

    context "MD5" do
      let(:options) { { hash_digest: Digest::MD5 } }

      it "returns a fingerprint" do
        expect(subject.fingerprint).to be_a String
        expect(subject.fingerprint).to eq "a790b00c9b5d58a8fd17a1ec5a187129"
      end
    end

    context "SHA256" do
      let(:options) { { hash_digest: Digest::SHA256 } }

      it "returns a fingerprint" do
        expect(subject.fingerprint).to be_a String
        expect(subject.fingerprint).
          to eq "243d7ce1099719df25f600f1c369c629fb979f88d5a01dbe7d0d48c8e6715bb1"
      end
    end
  end

  context "#original_filename=" do
    it "should not fail with a nil original filename" do
      expect { subject.original_filename = nil }.not_to raise_error
    end
  end

  context "#link_or_copy_file" do
    class TestLinkOrCopyAdapter < Paperclip::AbstractAdapter
      public :copy_to_tempfile, :destination
    end

    subject { TestLinkOrCopyAdapter.new(nil) }
    let(:body) { "body" }

    let(:file) do
      t = Tempfile.new("destination")
      t.print(body)
      t.rewind
      t
    end

    after do
      file.close
      file.unlink
    end

    it "should be able to read the file" do
      expect(subject.copy_to_tempfile(file).read).to eq(body)
    end

    it "should be able to reopen the file after symlink has failed" do
      FileUtils.expects(:ln).raises(Errno::EXDEV)

      expect(subject.copy_to_tempfile(file).read).to eq(body)
    end
  end
end
