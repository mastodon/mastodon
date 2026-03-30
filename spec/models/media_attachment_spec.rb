# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaAttachment, :attachment_processing do
  describe 'local?' do
    subject { media_attachment.local? }

    let(:media_attachment) { described_class.new(remote_url: remote_url) }

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

    let(:media_attachment) { described_class.new(remote_url: remote_url, file: file) }

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
    let(:media_attachment) { Fabricate.build(:media_attachment, shortcode: shortcode, id: id) }

    context 'when media attachment has a shortcode' do
      let(:shortcode) { 'foo' }
      let(:id) { 123 }

      it 'returns shortcode' do
        expect(media_attachment.to_param).to eq shortcode
      end
    end

    context 'when media attachment does not have a shortcode' do
      let(:shortcode) { nil }
      let(:id) { 123 }

      it 'returns string representation of id' do
        expect(media_attachment.to_param).to eq id.to_s
      end
    end
  end

  shared_examples 'static 600x400 image' do |content_type, extension|
    after do
      media.destroy
    end

    it 'saves media attachment with correct file and size metadata' do
      expect(media)
        .to be_persisted
        .and be_processing_complete
        .and have_attributes(
          file: be_present,
          type: eq('image'),
          file_content_type: eq(content_type),
          file_file_name: end_with(extension)
        )

      # Rack::Mime (used by PublicFileServerMiddleware) recognizes file extension
      expect(Rack::Mime.mime_type(extension, nil)).to eq content_type

      # Strip original file name
      expect(media.file_file_name)
        .to_not start_with '600x400'

      # Set meta for original and thumbnail
      expect(media.file.meta.deep_symbolize_keys)
        .to include(
          original: include(
            width: eq(600),
            height: eq(400),
            aspect: eq(1.5)
          ),
          small: include(
            width: eq(588),
            height: eq(392),
            aspect: eq(1.5)
          )
        )
    end
  end

  describe 'jpeg' do
    let(:media) { Fabricate(:media_attachment, file: attachment_fixture('600x400.jpeg')) }

    it_behaves_like 'static 600x400 image', 'image/jpeg', '.jpeg'
  end

  describe 'png' do
    let(:media) { Fabricate(:media_attachment, file: attachment_fixture('600x400.png')) }

    it_behaves_like 'static 600x400 image', 'image/png', '.png'
  end

  describe 'monochrome jpg' do
    let(:media) { Fabricate(:media_attachment, file: attachment_fixture('monochrome.png')) }

    it_behaves_like 'static 600x400 image', 'image/png', '.png'
  end

  describe 'webp' do
    let(:media) { Fabricate(:media_attachment, file: attachment_fixture('600x400.webp')) }

    it_behaves_like 'static 600x400 image', 'image/webp', '.webp'
  end

  describe 'avif' do
    let(:media) { Fabricate(:media_attachment, file: attachment_fixture('600x400.avif')) }

    it_behaves_like 'static 600x400 image', 'image/jpeg', '.jpeg'
  end

  describe 'heic' do
    let(:media) { Fabricate(:media_attachment, file: attachment_fixture('600x400.heic')) }

    it_behaves_like 'static 600x400 image', 'image/jpeg', '.jpeg'
  end

  describe 'base64-encoded image' do
    let(:base64_attachment) { "data:image/jpeg;base64,#{Base64.encode64(attachment_fixture('600x400.jpeg').read)}" }
    let(:media) { Fabricate(:media_attachment, file: base64_attachment) }

    it_behaves_like 'static 600x400 image', 'image/jpeg', '.jpeg'
  end

  describe 'animated gif' do
    let(:media) { Fabricate(:media_attachment, file: attachment_fixture('avatar.gif')) }

    it 'sets correct file metadata' do
      expect(media)
        .to have_attributes(
          type: eq('gifv'),
          file_content_type: eq('video/mp4')
        )
      expect(media_metadata)
        .to include(
          original: include(
            width: eq(128),
            height: eq(128)
          )
        )
    end
  end

  describe 'static gif' do
    fixtures = [
      { filename: 'attachment.gif', width: 600, height: 400, aspect: 1.5 },
      { filename: 'mini-static.gif', width: 32, height: 32, aspect: 1.0 },
    ]

    fixtures.each do |fixture|
      context fixture[:filename] do
        let(:media) { Fabricate(:media_attachment, file: attachment_fixture(fixture[:filename])) }

        it 'sets correct file metadata' do
          expect(media)
            .to have_attributes(
              type: eq('image'),
              file_content_type: eq('image/gif')
            )
          expect(media_metadata)
            .to include(
              original: include(
                width: eq(fixture[:width]),
                height: eq(fixture[:height]),
                aspect: eq(fixture[:aspect])
              )
            )
        end
      end
    end
  end

  describe 'ogg with cover art' do
    let(:media) { Fabricate(:media_attachment, file: attachment_fixture('boop.ogg')) }
    let(:expected_media_duration) { 0.235102 }
    let(:expected_background_color) { '#268cd9' }

    it 'sets correct file metadata' do
      expect(media)
        .to have_attributes(
          type: eq('audio'),
          thumbnail: be_present,
          file_file_name: not_eq('boop.ogg')
        )

      expect(media_metadata)
        .to include(
          original: include(duration: be_within(0.05).of(expected_media_duration)),
          colors: include(background: eq(expected_background_color))
        )
    end
  end

  describe 'mp3 with large cover art' do
    let(:media) { Fabricate(:media_attachment, file: attachment_fixture('boop.mp3')) }
    let(:expected_media_duration) { 0.235102 }

    it 'detects file type and sets correct metadata' do
      expect(media)
        .to have_attributes(
          type: eq('audio'),
          thumbnail: be_present,
          file_file_name: not_eq('boop.mp3')
        )
      expect(media_metadata)
        .to include(
          original: include(duration: be_within(0.05).of(expected_media_duration))
        )
    end
  end

  it { is_expected.to validate_presence_of(:file) }

  describe 'size limit validation' do
    it 'rejects video files that are too large' do
      stub_const 'MediaAttachment::IMAGE_LIMIT', 100.megabytes
      stub_const 'MediaAttachment::VIDEO_LIMIT', 1.kilobyte
      expect { Fabricate(:media_attachment, file: attachment_fixture('attachment.webm')) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'accepts video files that are small enough' do
      stub_const 'MediaAttachment::IMAGE_LIMIT', 1.kilobyte
      stub_const 'MediaAttachment::VIDEO_LIMIT', 100.megabytes
      media = Fabricate(:media_attachment, file: attachment_fixture('attachment.webm'))
      expect(media.valid?).to be true
    end

    it 'rejects image files that are too large' do
      stub_const 'MediaAttachment::IMAGE_LIMIT', 1.kilobyte
      stub_const 'MediaAttachment::VIDEO_LIMIT', 100.megabytes
      expect { Fabricate(:media_attachment, file: attachment_fixture('attachment.jpg')) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'accepts image files that are small enough' do
      stub_const 'MediaAttachment::IMAGE_LIMIT', 100.megabytes
      stub_const 'MediaAttachment::VIDEO_LIMIT', 1.kilobyte
      media = Fabricate(:media_attachment, file: attachment_fixture('attachment.jpg'))
      expect(media.valid?).to be true
    end
  end

  describe 'cache deletion hooks' do
    let(:media) { Fabricate(:media_attachment) }

    before do
      allow(Rails.configuration.x.cache_buster).to receive(:enabled).and_return(true)
    end

    it 'queues CacheBusterWorker jobs' do
      original_url = media.file.url(:original)
      small_url = media.file.url(:small)

      expect { media.destroy }
        .to enqueue_sidekiq_job(CacheBusterWorker).with(original_url)
        .and enqueue_sidekiq_job(CacheBusterWorker).with(small_url)
    end

    context 'with a missing remote attachment' do
      let(:media) { Fabricate(:media_attachment, remote_url: 'https://example.com/foo.png', file: nil) }

      it 'does not queue CacheBusterWorker jobs' do
        expect { media.destroy }
          .to_not enqueue_sidekiq_job(CacheBusterWorker)
      end
    end
  end

  describe '.combined_media_file_size' do
    subject { described_class.combined_media_file_size }

    it { is_expected.to be_an(Arel::Nodes::Grouping) }
  end

  private

  def media_metadata
    media.file.meta.deep_symbolize_keys
  end
end
