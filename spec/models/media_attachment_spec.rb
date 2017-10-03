require 'rails_helper'

RSpec.describe MediaAttachment, type: :model do
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
      expect(media.file.meta["original"]["aspect"]).to eq 1.0
    end
  end

  describe 'non-animated gif non-conversion' do
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture('attachment.gif')) }

    it 'sets type to image' do
      expect(media.type).to eq 'image'
    end

    it 'leaves original file as-is' do
      expect(media.file_content_type).to eq 'image/gif'
    end

    it 'sets meta' do
      expect(media.file.meta["original"]["width"]).to eq 600
      expect(media.file.meta["original"]["height"]).to eq 400
      expect(media.file.meta["original"]["aspect"]).to eq 1.5
    end
  end

  describe 'jpeg' do
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture('attachment.jpg')) }

    it 'sets meta for different style' do
      expect(media.file.meta["original"]["width"]).to eq 600
      expect(media.file.meta["original"]["height"]).to eq 400
      expect(media.file.meta["original"]["aspect"]).to eq 1.5
      expect(media.file.meta["small"]["width"]).to eq 400
      expect(media.file.meta["small"]["height"]).to eq 267
      expect(media.file.meta["small"]["aspect"]).to eq 400.0/267
    end
  end

  describe 'descriptions for remote attachments' do
    it 'are cut off at 140 characters' do
      media = Fabricate(:media_attachment, description: 'foo' * 1000, remote_url: 'http://example.com/blah.jpg')

      expect(media.description.size).to be <= 420
    end
  end
end
