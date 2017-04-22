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
  end

  describe 'non-animated gif non-conversion' do
    let(:media) { MediaAttachment.create(account: Fabricate(:account), file: attachment_fixture('attachment.gif')) }

    it 'sets type to image' do
      expect(media.type).to eq 'image'
    end

    it 'leaves original file as-is' do
      expect(media.file_content_type).to eq 'image/gif'
    end
  end
end
