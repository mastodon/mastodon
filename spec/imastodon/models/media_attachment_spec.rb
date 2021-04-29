require 'rails_helper'

RSpec.describe MediaAttachment, type: :model do
  describe 'jpgで保存したほうがサイズが小さくなる不透過pngはjpgに変換して保存する' do
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture('photo.png')) }

    it 'sets type to image' do
      expect(media.type).to eq 'image'
    end

    it 'file_content_typeと拡張子がjpegに設定されている' do
      expect(media.file_content_type).to eq 'image/jpeg'
      expect(media.file_file_name).to end_with 'jpeg'
    end

    it 'sets meta' do
      expect(media.file.meta["original"]["width"]).to eq 1280
      expect(media.file.meta["original"]["height"]).to eq 720
      expect(media.file.meta["original"]["aspect"]).to eq 1.7777777777777777
    end
  end

  describe 'pngで保存したほうがサイズが小さくなる不透過pngはpngのまま保存する' do
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture('not-transparent.png')) }

    it 'sets type to image' do
      expect(media.type).to eq 'image'
    end

    it 'file_content_typeと拡張子がpngのまま' do
      expect(media.file_content_type).to eq 'image/png'
      expect(media.file_file_name).to end_with 'png'
    end

    it 'sets meta' do
      expect(media.file.meta["original"]["width"]).to eq 1920
      expect(media.file.meta["original"]["height"]).to eq 1080
      expect(media.file.meta["original"]["aspect"]).to eq 1.7777777777777777
    end
  end

  describe '透過pngはpngのまま保存する' do
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture('transparent.png')) }

    it 'sets type to image' do
      expect(media.type).to eq 'image'
    end

    it 'file_content_typeと拡張子がpngのまま' do
      expect(media.file_content_type).to eq 'image/png'
      expect(media.file_file_name).to end_with 'png'
    end

    it 'sets meta' do
      expect(media.file.meta["original"]["width"]).to eq 1920
      expect(media.file.meta["original"]["height"]).to eq 1080
      expect(media.file.meta["original"]["aspect"]).to eq 1.7777777777777777
    end
  end
end
