require 'rails_helper'

describe Export do
  let(:account) { Fabricate(:account) }
  let(:target_accounts) do
    [ {}, { username: 'one', domain: 'local.host' } ].map(&method(:Fabricate).curry(2).call(:account))
  end

  describe 'to_csv' do
    it 'returns a csv of the blocked accounts' do
      target_accounts.each(&account.method(:block!))

      export = Export.new(account).to_blocked_accounts_csv
      results = export.strip.split

      expect(results.size).to eq 2
      expect(results.first).to eq 'one@local.host'
    end

    it 'returns a csv of the muted accounts' do
      target_accounts.each(&account.method(:mute!))

      export = Export.new(account).to_muted_accounts_csv
      results = export.strip.split

      expect(results.size).to eq 2
      expect(results.first).to eq 'one@local.host'
    end

    it 'returns a csv of the following accounts' do
      target_accounts.each(&account.method(:follow!))

      export = Export.new(account).to_following_accounts_csv
      results = export.strip.split

      expect(results.size).to eq 2
      expect(results.first).to eq 'one@local.host'
    end
  end

  describe 'total_storage' do
    it 'returns the total size of the media attachments' do
      media_attachment = Fabricate(:media_attachment, account: account)
      expect(Export.new(account).total_storage).to eq media_attachment.file_file_size || 0
    end
  end

  describe 'total_follows' do
    it 'returns the total number of the followed accounts' do
      target_accounts.each(&account.method(:follow!))
      expect(Export.new(account).total_follows).to eq 2
    end

    it 'returns the total number of the blocked accounts' do
      target_accounts.each(&account.method(:block!))
      expect(Export.new(account).total_blocks).to eq 2
    end

    it 'returns the total number of the muted accounts' do
      target_accounts.each(&account.method(:mute!))
      expect(Export.new(account).total_mutes).to eq 2
    end
  end
end
