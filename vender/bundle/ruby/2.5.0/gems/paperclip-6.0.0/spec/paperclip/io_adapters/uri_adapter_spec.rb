require 'spec_helper'

describe Paperclip::UriAdapter do
  let(:content_type) { "image/png" }
  let(:meta) { {} }

  before do
    @open_return = StringIO.new("xxx")
    @open_return.stubs(:content_type).returns(content_type)
    @open_return.stubs(:meta).returns(meta)
    Paperclip::UriAdapter.register
  end

  after do
    Paperclip.io_adapters.unregister(described_class)
  end

  context "a new instance" do
    before do
      Paperclip::UriAdapter.any_instance.
        stubs(:download_content).returns(@open_return)

      @uri = URI.parse("http://thoughtbot.com/images/thoughtbot-logo.png")
      @subject = Paperclip.io_adapters.for(@uri, hash_digest: Digest::MD5)
    end

    it "returns a file name" do
      assert_equal "thoughtbot-logo.png", @subject.original_filename
    end

    it 'closes open handle after reading' do
      assert_equal true, @open_return.closed?
    end

    it "returns a content type" do
      assert_equal "image/png", @subject.content_type
    end

    it "returns the size of the data" do
      assert_equal @open_return.size, @subject.size
    end

    it "generates an MD5 hash of the contents" do
      assert_equal Digest::MD5.hexdigest("xxx"), @subject.fingerprint
    end

    it "generates correct fingerprint after read" do
      fingerprint = Digest::MD5.hexdigest(@subject.read)
      assert_equal fingerprint, @subject.fingerprint
    end

    it "generates same fingerprint" do
      assert_equal @subject.fingerprint, @subject.fingerprint
    end

    it "returns the data contained in the StringIO" do
      assert_equal "xxx", @subject.read
    end

    it 'accepts a content_type' do
      @subject.content_type = 'image/png'
      assert_equal 'image/png', @subject.content_type
    end

    it 'accepts an orgiginal_filename' do
      @subject.original_filename = 'image.png'
      assert_equal 'image.png', @subject.original_filename
    end

  end

  context "a directory index url" do
    let(:content_type) { "text/html" }

    before do
      Paperclip::UriAdapter.any_instance.
        stubs(:download_content).returns(@open_return)

      @uri = URI.parse("http://thoughtbot.com")
      @subject = Paperclip.io_adapters.for(@uri)
    end

    it "returns a file name" do
      assert_equal "index.html", @subject.original_filename
    end

    it "returns a content type" do
      assert_equal "text/html", @subject.content_type
    end
  end

  context "a url with query params" do
    before do
      Paperclip::UriAdapter.any_instance.
        stubs(:download_content).returns(@open_return)

      @uri = URI.parse("https://github.com/thoughtbot/paperclip?file=test")
      @subject = Paperclip.io_adapters.for(@uri)
    end

    it "returns a file name" do
      assert_equal "paperclip", @subject.original_filename
    end
  end

  context "a url with content disposition headers" do
    let(:file_name) { "test_document.pdf" }
    let(:meta) do
      {
        "content-disposition" => "attachment; filename=\"#{file_name}\";",
      }
    end

    before do
      Paperclip::UriAdapter.any_instance.
        stubs(:download_content).returns(@open_return)

      @uri = URI.parse("https://github.com/thoughtbot/paperclip?file=test")
      @subject = Paperclip.io_adapters.for(@uri)
    end

    it "returns a file name" do
      assert_equal file_name, @subject.original_filename
    end
  end

  context "a url with restricted characters in the filename" do
    before do
      Paperclip::UriAdapter.any_instance.
        stubs(:download_content).returns(@open_return)

      @uri = URI.parse("https://github.com/thoughtbot/paper:clip.jpg")
      @subject = Paperclip.io_adapters.for(@uri)
    end

    it "does not generate filenames that include restricted characters" do
      assert_equal "paper_clip.jpg", @subject.original_filename
    end

    it "does not generate paths that include restricted characters" do
      expect(@subject.path).to_not match(/:/)
    end
  end

  describe "#download_content" do
    before do
      Paperclip::UriAdapter.any_instance.stubs(:open).returns(@open_return)
      @uri = URI.parse("https://github.com/thoughtbot/paper:clip.jpg")
      @subject = Paperclip.io_adapters.for(@uri)
    end

    after do
      @subject.send(:download_content)
    end

    context "with default read_timeout" do
      it "calls open without options" do
        @subject.expects(:open).with(@uri, {}).at_least_once
      end
    end

    context "with custom read_timeout" do
      before do
        Paperclip.options[:read_timeout] = 120
      end

      it "calls open with read_timeout option" do
        @subject.expects(:open).with(@uri, read_timeout: 120).at_least_once
      end
    end
  end
end
