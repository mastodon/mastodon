require 'rails_helper'

describe Export do
  describe 'to_csv' do
    it 'returns a csv of the accounts' do
      one = Account.new(username: 'one', domain: 'local.host')
      two = Account.new(username: 'two', domain: 'local.host')
      accounts = [one, two]

      export = Export.new(accounts).to_csv
      results = export.strip.split

      expect(results.size).to eq 2
      expect(results.first).to eq 'one@local.host'
    end
  end
end
