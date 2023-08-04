# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaAttachment, paperclip_processing: true do
  describe 'local?' do
    subject { media_attachment.local? }

    let(:media_attachment) { Fabricate(:media_attachment, remote_url: remote_url) }

    context 'when remote_url is blank' do
      let(:remote_url) { '' }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when remote_url is present' do
      let(:remote_url) { 'remote_url' }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe 'needs_redownload?' do
    subject { media_attachment.needs_redownload? }

    let(:media_attachment) { Fabricate(:media_attachment, remote_url: remote_url, file: file) }

    context 'when file is blank' do
      let(:file) { nil }

      context 'when remote_url is present' do
        let(:remote_url) { 'remote_url' }

        it 'returns true' do
          expect(subject).to be true
        end
      end
    end

    context 'when file is present' do
      let(:file) { attachment_fixture('avatar.gif') }

      context 'when remote_url is blank' do
        let(:remote_url) { '' }

        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when remote_url is present' do
        let(:remote_url) { 'remote_url' }

        it 'returns true' do
          expect(subject).to be false
        end
      end
    end
  end

  describe '#to_param' do
    let(:media_attachment) { Fabricate(:media_attachment, shortcode: shortcode) }
    let(:shortcode)        { nil }

    context 'when media attachment has a shortcode' do
      let(:shortcode) { 'foo' }

      it 'returns shortcode' do
        expect(media_attachment.to_param).to eq shortcode
      end
    end

    context 'when media attachment does not have a shortcode' do
      let(:shortcode) { nil }

      it 'returns string representation of id' do
        expect(media_attachment.to_param).to eq media_attachment.id.to_s
      end
    end
  end

  shared_examples 'static 600x400 image' do |content_type, extension|
    after do
      media.destroy
    end

    it 'saves media attachment' do
      expect(media.persisted?).to be true
      expect(media.file).to_not be_nil
    end

    it 'completes processing' do
      expect(media.processing_complete?).to be true
    end

    it 'sets type' do
      expect(media.type).to eq 'image'
    end

    it 'sets content type' do
      expect(media.file_content_type).to eq content_type
    end

    it 'sets file extension' do
      expect(media.file_file_name).to end_with extension
    end

    it 'strips original file name' do
      expect(media.file_file_name).to_not start_with '600x400'
    end

    it 'sets meta for original' do
      expect(media.file.meta['original']['width']).to eq 600
      expect(media.file.meta['original']['height']).to eq 400
      expect(media.file.meta['original']['aspect']).to eq 1.5
    end

    it 'sets meta for thumbnail' do
      expect(media.file.meta['small']['width']).to eq 588
      expect(media.file.meta['small']['height']).to eq 392
      expect(media.file.meta['small']['aspect']).to eq 1.5
    end
  end

  describe 'jpeg' do
    let(:media) { described_class.create(account: Fabricate(:account), file: attachment_fixture('600x400.jpeg')) }

    it_behaves_like 'static 600x400 image', 'image/jpeg', '.jpeg'
  end

  describe 'png' do
    let(:media) { described_class.create(account: Fabricate(:account), file: attachment_fixture('600x400.png')) }

    it_behaves_like 'static 600x400 image', 'image/png', '.png'
  end

  describe 'webp' do
    let(:media) { described_class.create(account: Fabricate(:account), file: attachment_fixture('600x400.webp')) }

    it_behaves_like 'static 600x400 image', 'image/webp', '.webp'
  end

  describe 'avif' do
    let(:media) { described_class.create(account: Fabricate(:account), file: attachment_fixture('600x400.avif')) }

    it_behaves_like 'static 600x400 image', 'image/jpeg', '.jpeg'
  end

  describe 'heic' do
    let(:media) { described_class.create(account: Fabricate(:account), file: attachment_fixture('600x400.heic')) }

    it_behaves_like 'static 600x400 image', 'image/jpeg', '.jpeg'
  end

  describe 'base64-encoded image' do
    let(:base64_attachment) { "data:image/jpeg;base64,#{Base64.encode64(attachment_fixture('600x400.jpeg').read)}" }
    let(:media) { described_class.create(account: Fabricate(:account), file: base64_attachment) }

    it_behaves_like 'static 600x400 image', 'image/jpeg', '.jpeg'
  end

  describe 'animated gif' do
    let(:media) { described_class.create(account: Fabricate(:account), file: attachment_fixture('avatar.gif')) }

    it 'sets type to gifv' do
      expect(media.type).to eq 'gifv'
    end

    it 'converts original file to mp4' do
      expect(media.file_content_type).to eq 'video/mp4'
    end

    it 'sets meta' do
      expect(media.file.meta['original']['width']).to eq 128
      expect(media.file.meta['original']['height']).to eq 128
    end
  end

  describe 'static gif' do
    fixtures = [
      { filename: 'attachment.gif', width: 600, height: 400, aspect: 1.5 },
      { filename: 'mini-static.gif', width: 32, height: 32, aspect: 1.0 },
    ]

    fixtures.each do |fixture|
      context fixture[:filename] do
        let(:media) { described_class.create(account: Fabricate(:account), file: attachment_fixture(fixture[:filename])) }

        it 'sets type to image' do
          expect(media.type).to eq 'image'
        end

        it 'leaves original file as-is' do
          expect(media.file_content_type).to eq 'image/gif'
        end

        it 'sets meta' do
          expect(media.file.meta['original']['width']).to eq fixture[:width]
          expect(media.file.meta['original']['height']).to eq fixture[:height]
          expect(media.file.meta['original']['aspect']).to eq fixture[:aspect]
        end
      end
    end
  end

  describe 'ogg with cover art' do
    let(:media) { described_class.create(account: Fabricate(:account), file: attachment_fixture('boop.ogg')) }

    it 'detects it as an audio file' do
      expect(media.type).to eq 'audio'
    end

    it 'sets meta for the duration' do
      expect(media.file.meta['original']['duration']).to be_within(0.05).of(0.235102)
    end

    it 'extracts thumbnail' do
      expect(media.thumbnail.present?).to be true
    end

    it 'extracts colors from thumbnail' do
      expect(media.file.meta['colors']['background']).to eq '#3088d4'
    end

    it 'gives the file a random name' do
      expect(media.file_file_name).to_not eq 'boop.ogg'
    end
  end

  describe 'mp3 with large cover art' do
    let(:media) { described_class.create(account: Fabricate(:account), file: attachment_fixture('boop.mp3')) }

    it 'detects it as an audio file' do
      expect(media.type).to eq 'audio'
    end

    it 'sets meta for the duration' do
      expect(media.file.meta['original']['duration']).to be_within(0.05).of(0.235102)
    end

    it 'extracts thumbnail' do
      expect(media.thumbnail.present?).to be true
    end

    it 'gives the file a random name' do
      expect(media.file_file_name).to_not eq 'boop.mp3'
    end
  end

  it 'is invalid without file' do
    media = described_class.new(account: Fabricate(:account))
    expect(media.valid?).to be false
  end

  describe 'size limit validation' do
    it 'rejects video files that are too large' do
      stub_const 'MediaAttachment::IMAGE_LIMIT', 100.megabytes
      stub_const 'MediaAttachment::VIDEO_LIMIT', 1.kilobyte
      expect { described_class.create!(account: Fabricate(:account), file: attachment_fixture('attachment.webm')) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'accepts video files that are small enough' do
      stub_const 'MediaAttachment::IMAGE_LIMIT', 1.kilobyte
      stub_const 'MediaAttachment::VIDEO_LIMIT', 100.megabytes
      media = described_class.create!(account: Fabricate(:account), file: attachment_fixture('attachment.webm'))
      expect(media.valid?).to be true
    end

    it 'rejects image files that are too large' do
      stub_const 'MediaAttachment::IMAGE_LIMIT', 1.kilobyte
      stub_const 'MediaAttachment::VIDEO_LIMIT', 100.megabytes
      expect { described_class.create!(account: Fabricate(:account), file: attachment_fixture('attachment.jpg')) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'accepts image files that are small enough' do
      stub_const 'MediaAttachment::IMAGE_LIMIT', 100.megabytes
      stub_const 'MediaAttachment::VIDEO_LIMIT', 1.kilobyte
      media = described_class.create!(account: Fabricate(:account), file: attachment_fixture('attachment.jpg'))
      expect(media.valid?).to be true
    end
  end
end
