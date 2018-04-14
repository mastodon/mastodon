require 'spec_helper'

describe Paperclip::HttpUrlProxyAdapter do
  before do
    @open_return = StringIO.new("xxx")
    @open_return.stubs(:content_type).returns("image/png")
    @open_return.stubs(:meta).returns({})
    Paperclip::HttpUrlProxyAdapter.any_instance.
      stubs(:download_content).returns(@open_return)
    Paperclip::HttpUrlProxyAdapter.register
  end

  after do
    Paperclip.io_adapters.unregister(described_class)
  end

  context "a new instance" do
    before do
      @url = "http://thoughtbot.com/images/thoughtbot-logo.png"
      @subject = Paperclip.io_adapters.for(@url, hash_digest: Digest::MD5)
    end

    after do
      @subject.close
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

    it 'accepts an original_filename' do
      @subject.original_filename = 'image.png'
      assert_equal 'image.png', @subject.original_filename
    end
  end

  context "a url with query params" do
    before do
      @url = "https://github.com/thoughtbot/paperclip?file=test"
      @subject = Paperclip.io_adapters.for(@url)
    end

    after do
      @subject.close
    end

    it "returns a file name" do
      assert_equal "paperclip", @subject.original_filename
    end
  end

  context "a url with restricted characters in the filename" do
    before do
      @url = "https://github.com/thoughtbot/paper:clip.jpg"
      @subject = Paperclip.io_adapters.for(@url)
    end

    after do
      begin
        @subject.close
      rescue Exception
        true
      end
    end

    it "does not generate filenames that include restricted characters" do
      assert_equal "paper_clip.jpg", @subject.original_filename
    end

    it "does not generate paths that include restricted characters" do
      expect(@subject.path).to_not match(/:/)
    end
  end

  context "a url with special characters in the filename" do
    it "returns a encoded filename" do
      Paperclip::HttpUrlProxyAdapter.any_instance.stubs(:download_content).
        returns(@open_return)
      url = "https://github.com/thoughtbot/paperclip-öäü字´½♥Ø²È.png"
      subject = Paperclip.io_adapters.for(url)
      filename = "paperclip-%C3%B6%C3%A4%C3%BC%E5%AD%97%C2%B4%C2%BD%E2%99%A5"\
        "%C3%98%C2%B2%C3%88.png"

      assert_equal filename, subject.original_filename
    end
  end
end
