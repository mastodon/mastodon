require 'rails_helper'

describe Export do
  describe 'to_csv' do
    before do
      one = Account.new(username: 'one', domain: 'local.host')
      two = Account.new(username: 'two', domain: 'local.host')
      accounts = [one, two]

      @account = double(blocking: accounts, muting: accounts, following: accounts)
    end

    it 'returns a csv of the blocked accounts' do
      export = Export.new(@account).to_blocked_accounts_csv
      results = export.strip.split

      expect(results.size).to eq 2
      expect(results.first).to eq 'one@local.host'
    end

    it 'returns a csv of the muted accounts' do
      export = Export.new(@account).to_muted_accounts_csv
      results = export.strip.split

      expect(results.size).to eq 2
      expect(results.first).to eq 'one@local.host'
    end

    it 'returns a csv of the following accounts' do
      export = Export.new(@account).to_following_accounts_csv
      results = export.strip.split

      expect(results.size).to eq 2
      expect(results.first).to eq 'one@local.host'
    end
  end
end
