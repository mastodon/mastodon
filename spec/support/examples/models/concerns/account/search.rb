# frozen_string_literal: true

RSpec.shared_examples 'Account::Search' do
  describe '.search_for' do
    before do
      _missing = Fabricate(
        :account,
        display_name: 'Missing',
        username: 'missing',
        domain: 'missing.com'
      )
    end

    it 'does not return suspended users' do
      Fabricate(
        :account,
        display_name: 'Display Name',
        username: 'username',
        domain: 'example.com',
        suspended: true
      )

      results = described_class.search_for('username')
      expect(results).to eq []
    end

    it 'does not return unapproved users' do
      match = Fabricate(
        :account,
        display_name: 'Display Name',
        username: 'username'
      )

      match.user.update(approved: false)

      results = described_class.search_for('username')
      expect(results).to eq []
    end

    it 'does not return unconfirmed users' do
      match = Fabricate(
        :account,
        display_name: 'Display Name',
        username: 'username'
      )

      match.user.update(confirmed_at: nil)

      results = described_class.search_for('username')
      expect(results).to eq []
    end

    it 'accepts ?, \, : and space as delimiter' do
      match = Fabricate(
        :account,
        display_name: 'A & l & i & c & e',
        username: 'username',
        domain: 'example.com'
      )

      results = described_class.search_for('A?l\i:c e')
      expect(results).to eq [match]
    end

    it 'finds accounts with matching display_name' do
      match = Fabricate(
        :account,
        display_name: 'Display Name',
        username: 'username',
        domain: 'example.com'
      )

      results = described_class.search_for('display')
      expect(results).to eq [match]
    end

    it 'finds accounts with matching username' do
      match = Fabricate(
        :account,
        display_name: 'Display Name',
        username: 'username',
        domain: 'example.com'
      )

      results = described_class.search_for('username')
      expect(results).to eq [match]
    end

    it 'finds accounts with matching domain' do
      match = Fabricate(
        :account,
        display_name: 'Display Name',
        username: 'username',
        domain: 'example.com'
      )

      results = described_class.search_for('example')
      expect(results).to eq [match]
    end

    it 'limits via constant by default' do
      stub_const('Account::Search::DEFAULT_LIMIT', 1)
      2.times.each { Fabricate(:account, display_name: 'Display Name') }
      results = described_class.search_for('display')
      expect(results.size).to eq 1
    end

    it 'accepts arbitrary limits' do
      2.times.each { Fabricate(:account, display_name: 'Display Name') }
      results = described_class.search_for('display', limit: 1)
      expect(results.size).to eq 1
    end

    it 'ranks multiple matches higher' do
      matches = [
        { username: 'username', display_name: 'username' },
        { display_name: 'Display Name', username: 'username', domain: 'example.com' },
      ].map(&method(:Fabricate).curry(2).call(:account))

      results = described_class.search_for('username')
      expect(results).to eq matches
    end
  end

  describe '.advanced_search_for' do
    let(:account) { Fabricate(:account) }

    context 'when limiting search to followed accounts' do
      it 'accepts ?, \, : and space as delimiter' do
        match = Fabricate(
          :account,
          display_name: 'A & l & i & c & e',
          username: 'username',
          domain: 'example.com'
        )
        account.follow!(match)

        results = described_class.advanced_search_for('A?l\i:c e', account, limit: 10, following: true)
        expect(results).to eq [match]
      end

      it 'does not return non-followed accounts' do
        Fabricate(
          :account,
          display_name: 'A & l & i & c & e',
          username: 'username',
          domain: 'example.com'
        )

        results = described_class.advanced_search_for('A?l\i:c e', account, limit: 10, following: true)
        expect(results).to eq []
      end

      it 'does not return suspended users' do
        Fabricate(
          :account,
          display_name: 'Display Name',
          username: 'username',
          domain: 'example.com',
          suspended: true
        )

        results = described_class.advanced_search_for('username', account, limit: 10, following: true)
        expect(results).to eq []
      end

      it 'does not return unapproved users' do
        match = Fabricate(
          :account,
          display_name: 'Display Name',
          username: 'username'
        )

        match.user.update(approved: false)

        results = described_class.advanced_search_for('username', account, limit: 10, following: true)
        expect(results).to eq []
      end

      it 'does not return unconfirmed users' do
        match = Fabricate(
          :account,
          display_name: 'Display Name',
          username: 'username'
        )

        match.user.update(confirmed_at: nil)

        results = described_class.advanced_search_for('username', account, limit: 10, following: true)
        expect(results).to eq []
      end
    end

    it 'does not return suspended users' do
      Fabricate(
        :account,
        display_name: 'Display Name',
        username: 'username',
        domain: 'example.com',
        suspended: true
      )

      results = described_class.advanced_search_for('username', account)
      expect(results).to eq []
    end

    it 'does not return unapproved users' do
      match = Fabricate(
        :account,
        display_name: 'Display Name',
        username: 'username'
      )

      match.user.update(approved: false)

      results = described_class.advanced_search_for('username', account)
      expect(results).to eq []
    end

    it 'does not return unconfirmed users' do
      match = Fabricate(
        :account,
        display_name: 'Display Name',
        username: 'username'
      )

      match.user.update(confirmed_at: nil)

      results = described_class.advanced_search_for('username', account)
      expect(results).to eq []
    end

    it 'accepts ?, \, : and space as delimiter' do
      match = Fabricate(
        :account,
        display_name: 'A & l & i & c & e',
        username: 'username',
        domain: 'example.com'
      )

      results = described_class.advanced_search_for('A?l\i:c e', account)
      expect(results).to eq [match]
    end

    it 'limits result count by default value' do
      stub_const('Account::Search::DEFAULT_LIMIT', 1)
      2.times { Fabricate(:account, display_name: 'Display Name') }
      results = described_class.advanced_search_for('display', account)
      expect(results.size).to eq 1
    end

    it 'accepts arbitrary limits' do
      2.times { Fabricate(:account, display_name: 'Display Name') }
      results = described_class.advanced_search_for('display', account, limit: 1)
      expect(results.size).to eq 1
    end

    it 'ranks followed accounts higher' do
      match = Fabricate(:account, username: 'Matching')
      followed_match = Fabricate(:account, username: 'Matcher')
      Fabricate(:follow, account: account, target_account: followed_match)

      results = described_class.advanced_search_for('match', account)
      expect(results).to eq [followed_match, match]
      expect(results.first.rank).to be > results.last.rank
    end
  end
end
