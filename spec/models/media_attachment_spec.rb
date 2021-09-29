require 'rails_helper'

RSpec.describe MediaAttachment, type: :model do
  describe 'local?' do
    let(:media_attachment) { Fabricate(:media_attachment, remote_url: remote_url) }

    subject { media_attachment.local? }

    context 'remote_url is blank' do
      let(:remote_url) { '' }

      it 'returns true' do
        is_expected.to be true
      end
    end

    context 'remote_url is present' do
      let(:remote_url) { 'remote_url' }

      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe 'needs_redownload?' do
    let(:media_attachment) { Fabricate(:media_attachment, remote_url: remote_url, file: file) }

    subject { media_attachment.needs_redownload? }

    context 'file is blank' do
      let(:file) { nil }

      context 'remote_url is present' do
        let(:remote_url) { 'remote_url' }

        it 'returns true' do
          is_expected.to be true
        end
      end
    end

    context 'file is present' do
      let(:file) { attachment_fixture('avatar.gif') }

      context 'remote_url is blank' do
        let(:remote_url) { '' }

        it 'returns false' do
          is_expected.to be false
        end
      end

      context 'remote_url is present' do
        let(:remote_url) { 'remote_url' }

        it 'returns true' do
          is_expected.to be false
        end
      end
    end
  end

  describe '#to_param' do
    let(:media_attachment) { Fabricate(:media_attachment) }
    let(:shortcode)        { media_attachment.shortcode }

    it 'returns shortcode' do
      expect(media_attachment.to_param).to eq shortcode
    end
  end

  describe 'animated gif conversion' do
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture('avatar.gif')) }

    it 'sets type to gifv' do
      expect(media.type).to eq 'gifv'
    end

    it 'converts original file to mp4' do
      expect(media.file_content_type).to eq 'video/mp4'
    end

    it 'sets meta' do
      expect(media.file.meta["original"]["width"]).to eq 128
      expect(media.file.meta["original"]["height"]).to eq 128
    end
  end

  describe 'non-animated gif non-conversion' do
    fixtures = [
      { filename: 'attachment.gif', width: 600, height: 400, aspect: 1.5 },
      { filename: 'mini-static.gif', width: 32, height: 32, aspect: 1.0 },
    ]

    fixtures.each do |fixture|
      context fixture[:filename] do
        let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture(fixture[:filename])) }

        it 'sets type to image' do
          expect(media.type).to eq 'image'
        end

        it 'leaves original file as-is' do
          expect(media.file_content_type).to eq 'image/gif'
        end

        it 'sets meta' do
          expect(media.file.meta["original"]["width"]).to eq fixture[:width]
          expect(media.file.meta["original"]["height"]).to eq fixture[:height]
          expect(media.file.meta["original"]["aspect"]).to eq fixture[:aspect]
        end
      end
    end
  end

  describe 'ogg with cover art' do
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture('boop.ogg')) }

    it 'detects it as an audio file' do
      expect(media.type).to eq 'audio'
    end

    it 'sets meta for the duration' do
      expect(media.file.meta['original']['duration']).to be_within(0.05).of(0.235102)
    end

    it 'extracts thumbnail' do
      expect(media.thumbnail.present?).to eq true
    end

    it 'extracts colors from thumbnail' do
      expect(media.file.meta['colors']['background']).to eq '#3088d4'
    end

    it 'gives the file a random name' do
      expect(media.file_file_name).to_not eq 'boop.ogg'
    end
  end

  describe 'jpeg' do
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture('attachment.jpg')) }

    it 'sets meta for different style' do
      expect(media.file.meta["original"]["width"]).to eq 600
      expect(media.file.meta["original"]["height"]).to eq 400
      expect(media.file.meta["original"]["aspect"]).to eq 1.5
      expect(media.file.meta["small"]["width"]).to eq 490
      expect(media.file.meta["small"]["height"]).to eq 327
      expect(media.file.meta["small"]["aspect"]).to eq 490.0 / 327
    end

    it 'gives the file a random name' do
      expect(media.file_file_name).to_not eq 'attachment.jpg'
    end
  end

  describe 'base64-encoded jpeg' do
    let(:base64_attachment) { "data:image/jpeg;base64,#{Base64.encode64(attachment_fixture('attachment.jpg').read)}" }
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: base64_attachment) }

    it 'saves media attachment' do
      expect(media.persisted?).to be true
      expect(media.file).to_not be_nil
    end

    it 'gives the file a file name' do
      expect(media.file_file_name).to_not be_blank
    end
  end

  it 'is invalid without file' do
    media = MediaAttachment.new(account: Fabricate(:account))
    expect(media.valid?).to be false
  end

  describe 'descriptions for remote attachments' do
    it 'are cut off at 1500 characters' do
      media = Fabricate(:media_attachment, description: 'foo' * 1000, remote_url: 'http://example.com/blah.jpg')

      expect(media.description.size).to be <= 1_500
    end
  end
end
