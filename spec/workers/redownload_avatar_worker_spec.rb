# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RedownloadAvatarWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    it 'returns nil for non-existent record' do
      result = worker.perform(123_123_123)

      expect(result).to be_nil
    end

    it 'returns nil for suspended account' do
      account = Fabricate(:account, suspended_at: 10.days.ago)

      expect(worker.perform(account.id)).to be_nil
    end

    it 'returns nil with a domain block' do
      account = Fabricate(:account, domain: 'host.example')
      Fabricate(:domain_block, domain: account.domain, reject_media: true)

      expect(worker.perform(account.id)).to be_nil
    end

    it 'returns nil without an avatar remote url' do
      account = Fabricate(:account, avatar_remote_url: '')

      expect(worker.perform(account.id)).to be_nil
    end

    it 'returns nil when avatar file name is present' do
      stub_request(:get, 'https://example.host/file').to_return request_fixture('avatar.txt')
      account = Fabricate(:account, avatar_remote_url: 'https://example.host/file', avatar_file_name: 'test.jpg')

      expect(worker.perform(account.id)).to be_nil
    end

    it 'reprocesses a remote avatar' do
      stub_request(:get, 'https://example.host/file').to_return request_fixture('avatar.txt')
      account = Fabricate(:account, avatar_remote_url: 'https://example.host/file')
      account.update_column(:avatar_file_name, nil)

      result = worker.perform(account.id)

      expect(result).to be(true)
      expect(account.reload.avatar_file_name).to_not be_nil
    end
  end
end
