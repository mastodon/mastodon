require 'spec_helper'

describe Paperclip::Transcoder do
  let(:supported) { File.new(Dir.pwd + '/spec/support/assets/sample.mp4') }
  let(:unsupported) { File.new(File.expand_path('spec/support/assets/image.png')) }

  let(:destination) { Pathname.new("#{Dir.tmpdir}/transcoder/") }

  describe "supported formats" do
    let(:subject) { Paperclip::Transcoder.new(supported) }
    let(:document) { Document.create(video: Rack::Test::UploadedFile.new(supported, 'video/mp4')) }

    describe ".transcode" do
      it { expect(File.exists?(document.video.path(:small))).to eq true }
      it { expect(File.exists?(document.video.path(:thumb))).to eq true }
    end
  end

  describe "unsupported formats" do
    let(:subject) { Paperclip::Transcoder.new(unsupported) }
    let(:document) { Document.create(image: Rack::Test::UploadedFile.new(unsupported, 'image/png')) }
    describe ".transcode" do
      it { expect(File.exists?(document.image.path(:small))).to eq true }
    end
  end

end