# frozen_string_literal: true

RSpec.shared_examples 'AccountAvatar' do |fabricator|
  describe 'static avatars', :attachment_processing do
    describe 'with a square GIF' do
      it 'creates a png static style' do
        account = Fabricate(fabricator, avatar: attachment_fixture('avatar.gif'))
        expect(account.avatar_static_url).to_not eq account.avatar_original_url
      end
    end

    describe 'with a higher-than-wide GIF' do
      it 'creates a png static style' do
        account = Fabricate(fabricator, avatar: attachment_fixture('avatar-high.gif'))
        expect(account.avatar_static_url).to_not eq account.avatar_original_url
      end
    end

    describe 'when non-GIF' do
      it 'does not create extra static style' do
        account = Fabricate(fabricator, avatar: attachment_fixture('attachment.jpg'))
        expect(account.avatar_static_url).to eq account.avatar_original_url
      end
    end
  end

  describe 'base64-encoded files', :attachment_processing do
    let(:base64_attachment) { "data:image/jpeg;base64,#{Base64.encode64(attachment_fixture('attachment.jpg').read)}" }
    let(:account) { Fabricate(fabricator, avatar: base64_attachment) }

    it 'saves avatar' do
      expect(account.persisted?).to be true
      expect(account.avatar).to_not be_nil
    end

    it 'gives the avatar a file name' do
      expect(account.avatar_file_name).to_not be_blank
    end

    it 'saves a new avatar under a different file name' do
      previous_file_name = account.avatar_file_name
      account.update(avatar: base64_attachment)
      expect(account.avatar_file_name).to_not eq previous_file_name
    end
  end
end
