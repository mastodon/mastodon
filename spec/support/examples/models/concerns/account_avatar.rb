# frozen_string_literal: true

shared_examples 'AccountAvatar' do |fabricator|
  describe 'static avatars' do
    describe 'when GIF' do
      it 'creates a png static style' do
        account = Fabricate(fabricator, avatar: attachment_fixture('avatar.gif'))
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
end
