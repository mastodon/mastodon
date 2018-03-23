require 'rails_helper'

RSpec.describe UpdateRemoteProfileService do
  let(:xml) { File.read(File.join(Rails.root, 'spec', 'fixtures', 'push', 'feed.atom')) }

  subject { UpdateRemoteProfileService.new }

  before do
    stub_request(:get, 'https://quitter.no/avatar/7477-300-20160211190340.png').to_return(request_fixture('avatar.txt'))
  end

  context 'with updated details' do
    let(:remote_account) { Fabricate(:account, username: 'bob', domain: 'example.com') }

    before do
      subject.call(xml, remote_account)
    end

    it 'downloads new avatar' do
      expect(a_request(:get, 'https://quitter.no/avatar/7477-300-20160211190340.png')).to have_been_made
    end

    it 'sets the avatar remote url' do
      expect(remote_account.reload.avatar_remote_url).to eq 'https://quitter.no/avatar/7477-300-20160211190340.png'
    end

    it 'sets display name' do
      expect(remote_account.reload.display_name).to eq 'ＤＩＧＩＴＡＬ ＣＡＴ'
    end

    it 'sets note' do
      expect(remote_account.reload.note).to eq 'Software engineer, free time musician and ＤＩＧＩＴＡＬ ＳＰＯＲＴＳ enthusiast. Likes cats. Warning: May contain memes'
    end
  end

  context 'with unchanged details' do
    let(:remote_account) { Fabricate(:account, username: 'bob', domain: 'example.com', display_name: 'ＤＩＧＩＴＡＬ ＣＡＴ', note: 'Software engineer, free time musician and ＤＩＧＩＴＡＬ ＳＰＯＲＴＳ enthusiast. Likes cats. Warning: May contain memes', avatar_remote_url: 'https://quitter.no/avatar/7477-300-20160211190340.png') }

    before do
      subject.call(xml, remote_account)
    end

    it 'does not re-download avatar' do
      expect(a_request(:get, 'https://quitter.no/avatar/7477-300-20160211190340.png')).to have_been_made.once
    end

    it 'sets the avatar remote url' do
      expect(remote_account.reload.avatar_remote_url).to eq 'https://quitter.no/avatar/7477-300-20160211190340.png'
    end

    it 'sets display name' do
      expect(remote_account.reload.display_name).to eq 'ＤＩＧＩＴＡＬ ＣＡＴ'
    end

    it 'sets note' do
      expect(remote_account.reload.note).to eq 'Software engineer, free time musician and ＤＩＧＩＴＡＬ ＳＰＯＲＴＳ enthusiast. Likes cats. Warning: May contain memes'
    end
  end

  context 'with updated details from a domain set to reject media' do
    let(:remote_account) { Fabricate(:account, username: 'bob', domain: 'example.com') }
    let!(:domain_block) { Fabricate(:domain_block, domain: 'example.com', reject_media: true) }

    before do
      subject.call(xml, remote_account)
    end

    it 'does not the avatar remote url' do
      expect(remote_account.reload.avatar_remote_url).to be_nil
    end

    it 'sets display name' do
      expect(remote_account.reload.display_name).to eq 'ＤＩＧＩＴＡＬ ＣＡＴ'
    end

    it 'sets note' do
      expect(remote_account.reload.note).to eq 'Software engineer, free time musician and ＤＩＧＩＴＡＬ ＳＰＯＲＴＳ enthusiast. Likes cats. Warning: May contain memes'
    end

    it 'does not set store the avatar' do
      expect(remote_account.reload.avatar_file_name).to be_nil
    end
  end
end
