require 'spec_helper'

describe Paperclip::MediaTypeSpoofDetector do
  it 'rejects a file that is named .html and identifies as PNG' do
    file = File.open(fixture_file("5k.png"))
    assert Paperclip::MediaTypeSpoofDetector.using(file, "5k.html", "image/png").spoofed?
  end

  it 'does not reject a file that is named .jpg and identifies as PNG' do
    file = File.open(fixture_file("5k.png"))
    assert ! Paperclip::MediaTypeSpoofDetector.using(file, "5k.jpg", "image/png").spoofed?
  end

  it 'does not reject a file that is named .html and identifies as HTML' do
    file = File.open(fixture_file("empty.html"))
    assert ! Paperclip::MediaTypeSpoofDetector.using(file, "empty.html", "text/html").spoofed?
  end

  it 'does not reject a file that does not have a name' do
    file = File.open(fixture_file("empty.html"))
    assert ! Paperclip::MediaTypeSpoofDetector.using(file, "", "text/html").spoofed?
  end

  it 'does not reject a file that does have an extension' do
    file = File.open(fixture_file("empty.html"))
    assert ! Paperclip::MediaTypeSpoofDetector.using(file, "data", "text/html").spoofed?
  end

  it 'does not reject when the supplied file is an IOAdapter' do
    adapter = Paperclip.io_adapters.for(File.new(fixture_file("5k.png")))
    assert ! Paperclip::MediaTypeSpoofDetector.using(adapter, adapter.original_filename, adapter.content_type).spoofed?
  end

  it 'does not reject when the extension => content_type is in :content_type_mappings' do
    begin
      Paperclip.options[:content_type_mappings] = { pem: "text/plain" }
      file = Tempfile.open(["test", ".PEM"])
      file.puts "Certificate!"
      file.close
      adapter = Paperclip.io_adapters.for(File.new(file.path));
      assert ! Paperclip::MediaTypeSpoofDetector.using(adapter, adapter.original_filename, adapter.content_type).spoofed?
    ensure
      Paperclip.options[:content_type_mappings] = {}
    end
  end

  context "file named .html and is as HTML, but we're told JPG" do
    let(:file) { File.open(fixture_file("empty.html")) }
    let(:spoofed?) { Paperclip::MediaTypeSpoofDetector.using(file, "empty.html", "image/jpg").spoofed? }

    it "rejects the file" do
      assert spoofed?
    end

    it "logs info about the detected spoof" do
      Paperclip.expects(:log).with('Content Type Spoof: Filename empty.html (image/jpg from Headers, ["text/html"] from Extension), content type discovered from file command: text/html. See documentation to allow this combination.')
      spoofed?
    end
  end

  it "does not reject if content_type is empty but otherwise checks out" do
    file = File.open(fixture_file("empty.html"))
    assert ! Paperclip::MediaTypeSpoofDetector.using(file, "empty.html", "").spoofed?
  end

  it 'does allow array as :content_type_mappings' do
    begin
      Paperclip.options[:content_type_mappings] = {
        html: ['binary', 'text/html']
      }
      file = File.open(fixture_file('empty.html'))
      spoofed = Paperclip::MediaTypeSpoofDetector
                .using(file, "empty.html", "text/html").spoofed?
      assert !spoofed
    ensure
      Paperclip.options[:content_type_mappings] = {}
    end
  end

  context "#type_from_file_command" do
    let(:file) { File.new(fixture_file("empty.html")) }
    let(:detector) { Paperclip::MediaTypeSpoofDetector.new(file, "html", "") }

    it "does work with the output of old versions of file" do
      Paperclip.stubs(:run).returns("text/html charset=us-ascii")
      expect(detector.send(:type_from_file_command)).to eq("text/html")
    end

    it "does work with the output of new versions of file" do
      Paperclip.stubs(:run).returns("text/html; charset=us-ascii")
      expect(detector.send(:type_from_file_command)).to eq("text/html")
    end
  end
end
