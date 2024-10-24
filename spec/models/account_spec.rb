# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account do
  include_examples 'Reviewable'

  context 'with an account record' do
    subject { Fabricate(:account) }

    let(:bob) { Fabricate(:account, username: 'bob') }

    describe '#follow!' do
      it 'creates a follow' do
        follow = subject.follow!(bob)

        expect(follow).to be_instance_of Follow
        expect(follow.account).to eq subject
        expect(follow.target_account).to eq bob
      end
    end

    describe '#unfollow!' do
      before do
        subject.follow!(bob)
      end

      it 'destroys a follow' do
        unfollow = subject.unfollow!(bob)

        expect(unfollow).to be_instance_of Follow
        expect(unfollow.account).to eq subject
        expect(unfollow.target_account).to eq bob
        expect(unfollow.destroyed?).to be true
      end
    end

    describe '#following?' do
      it 'returns true when the target is followed' do
        subject.follow!(bob)
        expect(subject.following?(bob)).to be true
      end

      it 'returns false if the target is not followed' do
        expect(subject.following?(bob)).to be false
      end
    end
  end

  describe '#local?' do
    it 'returns true when the account is local' do
      account = Fabricate(:account, domain: nil)
      expect(account.local?).to be true
    end

    it 'returns false when the account is on a different domain' do
      account = Fabricate(:account, domain: 'foreign.tld')
      expect(account.local?).to be false
    end
  end

  describe 'Local domain user methods' do
    subject { Fabricate(:account, domain: nil, username: 'alice') }

    around do |example|
      before = Rails.configuration.x.local_domain
      example.run
      Rails.configuration.x.local_domain = before
    end

    describe '#to_webfinger_s' do
      it 'returns a webfinger string for the account' do
        Rails.configuration.x.local_domain = 'example.com'

        expect(subject.to_webfinger_s).to eq 'acct:alice@example.com'
      end
    end

    describe '#local_username_and_domain' do
      it 'returns the username and local domain for the account' do
        Rails.configuration.x.local_domain = 'example.com'

        expect(subject.local_username_and_domain).to eq 'alice@example.com'
      end
    end
  end

  describe '#acct' do
    it 'returns username for local users' do
      account = Fabricate(:account, domain: nil, username: 'alice')
      expect(account.acct).to eql 'alice'
    end

    it 'returns username@domain for foreign users' do
      account = Fabricate(:account, domain: 'foreign.tld', username: 'alice')
      expect(account.acct).to eql 'alice@foreign.tld'
    end
  end

  describe '#save_with_optional_media!' do
    before do
      stub_request(:get, 'https://remote.test/valid_avatar').to_return(request_fixture('avatar.txt'))
      stub_request(:get, 'https://remote.test/invalid_avatar').to_return(request_fixture('feed.txt'))
    end

    let(:account) do
      Fabricate(:account,
                avatar_remote_url: 'https://remote.test/valid_avatar',
                header_remote_url: 'https://remote.test/valid_avatar')
    end

    let!(:expectation) { account.dup }

    context 'with valid properties' do
      before do
        account.save_with_optional_media!
      end

      it 'unchanges avatar, header, avatar_remote_url, and header_remote_url' do
        expect(account.avatar_remote_url).to eq expectation.avatar_remote_url
        expect(account.header_remote_url).to eq expectation.header_remote_url
        expect(account.avatar_file_name).to  eq expectation.avatar_file_name
        expect(account.header_file_name).to  eq expectation.header_file_name
      end
    end

    context 'with invalid properties' do
      before do
        account.avatar_remote_url = 'https://remote.test/invalid_avatar'
        account.save_with_optional_media!
      end

      it 'sets default avatar, header, avatar_remote_url, and header_remote_url' do
        expect(account.avatar_remote_url).to eq 'https://remote.test/invalid_avatar'
        expect(account.header_remote_url).to eq expectation.header_remote_url
        expect(account.avatar_file_name).to  be_nil
        expect(account.header_file_name).to  eq expectation.header_file_name
      end
    end
  end

  describe '#possibly_stale?' do
    let(:account) { Fabricate(:account, last_webfingered_at: last_webfingered_at) }

    context 'when last_webfingered_at is nil' do
      let(:last_webfingered_at) { nil }

      it 'returns true' do
        expect(account.possibly_stale?).to be true
      end
    end

    context 'when last_webfingered_at is before the threshold' do
      let(:last_webfingered_at) { (described_class::STALE_THRESHOLD + 1.hour).ago }

      it 'returns true' do
        expect(account.possibly_stale?).to be true
      end
    end

    context 'when last_webfingered_at is after the threshold' do
      let(:last_webfingered_at) { (described_class::STALE_THRESHOLD - 1.hour).ago }

      it 'returns false' do
        expect(account.possibly_stale?).to be false
      end
    end
  end

  describe '#refresh!' do
    let(:account) { Fabricate(:account, domain: domain) }
    let(:acct)    { account.acct }

    context 'when domain is nil' do
      let(:domain) { nil }

      it 'returns nil' do
        expect(account.refresh!).to be_nil
      end

      it 'does not call ResolveAccountService#call' do
        service = instance_double(ResolveAccountService, call: nil)
        allow(ResolveAccountService).to receive(:new).and_return(service)

        account.refresh!

        expect(service).to_not have_received(:call).with(acct)
      end
    end

    context 'when domain is present' do
      let(:domain) { 'example.com' }

      it 'calls ResolveAccountService#call' do
        service = instance_double(ResolveAccountService, call: nil)
        allow(ResolveAccountService).to receive(:new).and_return(service)

        account.refresh!

        expect(service).to have_received(:call).with(acct).once
      end
    end
  end

  describe '#to_param' do
    it 'returns username' do
      account = Fabricate(:account, username: 'alice')
      expect(account.to_param).to eq 'alice'
    end
  end

  describe '#keypair' do
    it 'returns an RSA key pair' do
      account = Fabricate(:account)
      expect(account.keypair).to be_instance_of OpenSSL::PKey::RSA
    end
  end

  describe '#object_type' do
    it 'is always a person' do
      account = Fabricate(:account)
      expect(account.object_type).to be :person
    end
  end

  describe '#favourited?' do
    subject { Fabricate(:account) }

    let(:original_status) do
      author = Fabricate(:account, username: 'original')
      Fabricate(:status, account: author)
    end

    context 'when the status is a reblog of another status' do
      let(:original_reblog) do
        author = Fabricate(:account, username: 'original_reblogger')
        Fabricate(:status, reblog: original_status, account: author)
      end

      it 'is true when this account has favourited it' do
        Fabricate(:favourite, status: original_reblog, account: subject)

        expect(subject.favourited?(original_status)).to be true
      end

      it 'is false when this account has not favourited it' do
        expect(subject.favourited?(original_status)).to be false
      end
    end

    context 'when the status is an original status' do
      it 'is true when this account has favourited it' do
        Fabricate(:favourite, status: original_status, account: subject)

        expect(subject.favourited?(original_status)).to be true
      end

      it 'is false when this account has not favourited it' do
        expect(subject.favourited?(original_status)).to be false
      end
    end
  end

  describe '#reblogged?' do
    subject { Fabricate(:account) }

    let(:original_status) do
      author = Fabricate(:account, username: 'original')
      Fabricate(:status, account: author)
    end

    context 'when the status is a reblog of another status' do
      let(:original_reblog) do
        author = Fabricate(:account, username: 'original_reblogger')
        Fabricate(:status, reblog: original_status, account: author)
      end

      it 'is true when this account has reblogged it' do
        Fabricate(:status, reblog: original_reblog, account: subject)

        expect(subject.reblogged?(original_reblog)).to be true
      end

      it 'is false when this account has not reblogged it' do
        expect(subject.reblogged?(original_reblog)).to be false
      end
    end

    context 'when the status is an original status' do
      it 'is true when this account has reblogged it' do
        Fabricate(:status, reblog: original_status, account: subject)

        expect(subject.reblogged?(original_status)).to be true
      end

      it 'is false when this account has not reblogged it' do
        expect(subject.reblogged?(original_status)).to be false
      end
    end
  end

  describe '#excluded_from_timeline_account_ids' do
    it 'includes account ids of blockings, blocked_bys and mutes' do
      account = Fabricate(:account)
      block = Fabricate(:block, account: account)
      mute = Fabricate(:mute, account: account)
      block_by = Fabricate(:block, target_account: account)

      results = account.excluded_from_timeline_account_ids
      expect(results.size).to eq 3
      expect(results).to include(
        block.target_account.id,
        mute.target_account.id,
        block_by.account.id
      )
    end
  end

  describe '#excluded_from_timeline_domains' do
    it 'returns the domains blocked by the account' do
      account = Fabricate(:account)
      account.block_domain!('domain')
      expect(account.excluded_from_timeline_domains).to contain_exactly('domain')
    end
  end

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

  describe '#statuses_count' do
    subject { Fabricate(:account) }

    it 'counts statuses' do
      Fabricate(:status, account: subject)
      Fabricate(:status, account: subject)
      expect(subject.statuses_count).to eq 2
    end

    it 'does not count direct statuses' do
      Fabricate(:status, account: subject, visibility: :direct)
      expect(subject.statuses_count).to eq 0
    end

    it 'is decremented when status is removed' do
      status = Fabricate(:status, account: subject)
      expect(subject.statuses_count).to eq 1
      status.destroy
      expect(subject.statuses_count).to eq 0
    end

    it 'is decremented when status is removed when account is not preloaded' do
      status = Fabricate(:status, account: subject)
      expect(subject.reload.statuses_count).to eq 1
      clean_status = Status.find(status.id)
      expect(clean_status.association(:account).loaded?).to be false
      clean_status.destroy
      expect(subject.reload.statuses_count).to eq 0
    end
  end

  describe '.following_map' do
    it 'returns an hash' do
      expect(described_class.following_map([], 1)).to be_a Hash
    end
  end

  describe '.followed_by_map' do
    it 'returns an hash' do
      expect(described_class.followed_by_map([], 1)).to be_a Hash
    end
  end

  describe '.blocking_map' do
    it 'returns an hash' do
      expect(described_class.blocking_map([], 1)).to be_a Hash
    end
  end

  describe '.requested_map' do
    it 'returns an hash' do
      expect(described_class.requested_map([], 1)).to be_a Hash
    end
  end

  describe '.requested_by_map' do
    it 'returns an hash' do
      expect(described_class.requested_by_map([], 1)).to be_a Hash
    end
  end

  describe 'MENTION_RE' do
    subject { described_class::MENTION_RE }

    it 'matches usernames in the middle of a sentence' do
      expect(subject.match('Hello to @alice from me')[1]).to eq 'alice'
    end

    it 'matches usernames in the beginning of status' do
      expect(subject.match('@alice Hey how are you?')[1]).to eq 'alice'
    end

    it 'matches full usernames' do
      expect(subject.match('@alice@example.com')[1]).to eq 'alice@example.com'
    end

    it 'matches full usernames with a dot at the end' do
      expect(subject.match('Hello @alice@example.com.')[1]).to eq 'alice@example.com'
    end

    it 'matches dot-prepended usernames' do
      expect(subject.match('.@alice I want everybody to see this')[1]).to eq 'alice'
    end

    it 'does not match e-mails' do
      expect(subject.match('Drop me an e-mail at alice@example.com')).to be_nil
    end

    it 'does not match URLs' do
      expect(subject.match('Check this out https://medium.com/@alice/some-article#.abcdef123')).to be_nil
    end

    it 'does not match URL query string' do
      expect(subject.match('https://example.com/?x=@alice')).to be_nil
    end

    it 'matches usernames immediately following the letter ß' do
      expect(subject.match('Hello toß @alice from me')[1]).to eq 'alice'
    end

    it 'matches usernames containing uppercase characters' do
      expect(subject.match('Hello to @aLice@Example.com from me')[1]).to eq 'aLice@Example.com'
    end
  end

  describe 'Callbacks' do
    describe 'Stripping content when required' do
      context 'with a remote account' do
        subject { Fabricate.build :account, domain: 'host.example', note: '   note   ', display_name: '   display name   ' }

        it 'preserves content' do
          expect { subject.valid? }
            .to not_change(subject, :note)
            .and not_change(subject, :display_name)
        end
      end

      context 'with a local account' do
        subject { Fabricate.build :account, domain: nil, note:, display_name: }

        context 'with populated fields' do
          let(:note) { '   note   ' }
          let(:display_name) { '   display name   ' }

          it 'strips content' do
            expect { subject.valid? }
              .to change(subject, :note).to('note')
              .and change(subject, :display_name).to('display name')
          end
        end

        context 'with empty fields' do
          let(:note) { nil }
          let(:display_name) { nil }

          it 'preserves content' do
            expect { subject.valid? }
              .to not_change(subject, :note)
              .and not_change(subject, :display_name)
          end
        end
      end
    end
  end

  describe '#can_be_attributed_from?' do
    subject { Fabricate(:account, attribution_domains: %w(example.com)) }

    it 'returns true for a matching domain' do
      expect(subject.can_be_attributed_from?('example.com')).to be true
    end

    it 'returns true for a subdomain of a domain' do
      expect(subject.can_be_attributed_from?('foo.example.com')).to be true
    end

    it 'returns false for a non-matching domain' do
      expect(subject.can_be_attributed_from?('hoge.com')).to be false
    end
  end

  describe '#attribution_domains_as_text=' do
    subject { Fabricate(:account) }

    it 'sets attribution_domains accordingly' do
      subject.attribution_domains_as_text = "hoge.com\nexample.com"

      expect(subject.attribution_domains).to contain_exactly('hoge.com', 'example.com')
    end

    it 'strips leading "*."' do
      subject.attribution_domains_as_text = "hoge.com\n*.example.com"

      expect(subject.attribution_domains).to contain_exactly('hoge.com', 'example.com')
    end

    it 'strips the protocol if present' do
      subject.attribution_domains_as_text = "http://hoge.com\nhttps://example.com"

      expect(subject.attribution_domains).to contain_exactly('hoge.com', 'example.com')
    end

    it 'strips a combination of leading "*." and protocol' do
      subject.attribution_domains_as_text = "http://*.hoge.com\nhttps://*.example.com"

      expect(subject.attribution_domains).to contain_exactly('hoge.com', 'example.com')
    end
  end

  describe 'Normalizations' do
    describe 'username' do
      it { is_expected.to normalize(:username).from(" \u3000bob \t \u00a0 \n ").to('bob') }
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:username) }

    context 'when account is local' do
      subject { Fabricate.build :account, domain: nil }

      context 'with an existing differently-cased username account' do
        before { Fabricate :account, username: 'the_doctor' }

        it { is_expected.to_not allow_value('the_Doctor').for(:username) }
      end

      it { is_expected.to_not allow_value('support').for(:username) }

      it 'is valid when username is reserved but record has already been created' do
        account = Fabricate.build(:account, username: 'support')
        account.save(validate: false)
        expect(account.valid?).to be true
      end

      context 'with the instance actor' do
        subject { Fabricate.build :account, id: described_class::INSTANCE_ACTOR_ID, actor_type: 'Application', locked: true }

        it { is_expected.to allow_value('example.com').for(:username) }
      end

      it 'is valid if we are creating a possibly-conflicting instance actor account' do
        _account = Fabricate(:account, username: 'examplecom')
        instance_account = Fabricate.build(:account, id: described_class::INSTANCE_ACTOR_ID, actor_type: 'Application', locked: true, username: 'example.com')
        expect(instance_account.valid?).to be true
      end

      it { is_expected.to_not allow_values('the-doctor', 'the.doctor').for(:username) }

      it { is_expected.to validate_length_of(:username).is_at_most(described_class::USERNAME_LENGTH_LIMIT) }
      it { is_expected.to validate_length_of(:display_name).is_at_most(described_class::DISPLAY_NAME_LENGTH_LIMIT) }

      it { is_expected.to_not allow_values(account_note_over_limit).for(:note) }
    end

    context 'when account is remote' do
      subject { Fabricate.build :account, domain: 'host.example' }

      context 'when a normalized domain account exists' do
        subject { Fabricate.build :account, domain: 'xn--r9j5b5b' }

        before { Fabricate(:account, domain: 'にゃん', username: 'username') }

        it { is_expected.to_not allow_values('username', 'Username').for(:username) }
      end

      it { is_expected.to allow_values('the-doctor', username_over_limit).for(:username) }
      it { is_expected.to_not allow_values('the doctor').for(:username) }

      it { is_expected.to allow_values(display_name_over_limit).for(:display_name) }

      it { is_expected.to allow_values(account_note_over_limit).for(:note) }
    end

    def username_over_limit
      'a' * described_class::USERNAME_LENGTH_LIMIT * 2
    end

    def display_name_over_limit
      'a' * described_class::DISPLAY_NAME_LENGTH_LIMIT * 2
    end

    def account_note_over_limit
      'a' * described_class::NOTE_LENGTH_LIMIT * 2
    end
  end

  describe 'scopes' do
    describe 'matches_uri_prefix' do
      let!(:alice) { Fabricate :account, domain: 'host.example', uri: 'https://host.example/user/a' }
      let!(:bob) { Fabricate :account, domain: 'top-level.example', uri: 'https://top-level.example' }

      it 'returns accounts which start with the value' do
        results = described_class.matches_uri_prefix('https://host.example')

        expect(results.size)
          .to eq(1)
        expect(results)
          .to include(alice)
          .and not_include(bob)
      end

      it 'returns accounts which equal the value' do
        results = described_class.matches_uri_prefix('https://top-level.example')

        expect(results.size)
          .to eq(1)
        expect(results)
          .to include(bob)
          .and not_include(alice)
      end
    end

    describe 'auditable' do
      let!(:alice) { Fabricate :account }
      let!(:bob) { Fabricate :account }

      before do
        2.times { Fabricate :action_log, account: alice }
      end

      it 'returns distinct accounts with action log records' do
        results = described_class.auditable

        expect(results.size)
          .to eq(1)
        expect(results)
          .to include(alice)
          .and not_include(bob)
      end
    end

    describe 'alphabetic' do
      it 'sorts by alphabetic order of domain and username' do
        matches = [
          { username: 'a', domain: 'a' },
          { username: 'b', domain: 'a' },
          { username: 'a', domain: 'b' },
          { username: 'b', domain: 'b' },
        ].map(&method(:Fabricate).curry(2).call(:account))

        expect(described_class.without_internal.alphabetic).to eq matches
      end
    end

    describe 'matches_display_name' do
      it 'matches display name which starts with the given string' do
        match = Fabricate(:account, display_name: 'pattern and suffix')
        Fabricate(:account, display_name: 'prefix and pattern')

        expect(described_class.matches_display_name('pattern')).to eq [match]
      end
    end

    describe 'matches_username' do
      it 'matches display name which starts with the given string' do
        match = Fabricate(:account, username: 'pattern_and_suffix')
        Fabricate(:account, username: 'prefix_and_pattern')

        expect(described_class.matches_username('pattern')).to eq [match]
      end
    end

    describe 'by_domain_and_subdomains' do
      it 'returns exact domain matches' do
        account = Fabricate(:account, domain: 'example.com')
        expect(described_class.by_domain_and_subdomains('example.com')).to eq [account]
      end

      it 'returns subdomains' do
        account = Fabricate(:account, domain: 'foo.example.com')
        expect(described_class.by_domain_and_subdomains('example.com')).to eq [account]
      end

      it 'does not return partially matching domains' do
        account = Fabricate(:account, domain: 'grexample.com')
        expect(described_class.by_domain_and_subdomains('example.com')).to_not eq [account]
      end
    end

    describe 'remote' do
      it 'returns an array of accounts who have a domain' do
        _account = Fabricate(:account, domain: nil)
        account_with_domain = Fabricate(:account, domain: 'example.com')
        expect(described_class.remote).to contain_exactly(account_with_domain)
      end
    end

    describe 'local' do
      it 'returns an array of accounts who do not have a domain' do
        local_account = Fabricate(:account, domain: nil)
        _account_with_domain = Fabricate(:account, domain: 'example.com')
        expect(described_class.without_internal.local).to contain_exactly(local_account)
      end
    end

    describe 'partitioned' do
      it 'returns a relation of accounts partitioned by domain' do
        matches = %w(a b a b)
        matches.size.times.to_a.shuffle.each do |index|
          matches[index] = Fabricate(:account, domain: matches[index])
        end

        expect(described_class.without_internal.partitioned).to match_array(matches)
      end
    end

    describe 'recent' do
      it 'returns a relation of accounts sorted by recent creation' do
        matches = Array.new(2) { Fabricate(:account) }
        expect(described_class.without_internal.recent).to match_array(matches)
      end
    end

    describe 'silenced' do
      it 'returns an array of accounts who are silenced' do
        silenced_account = Fabricate(:account, silenced: true)
        _account = Fabricate(:account, silenced: false)
        expect(described_class.silenced).to contain_exactly(silenced_account)
      end
    end

    describe 'searchable' do
      let!(:suspended_local)        { Fabricate(:account, suspended: true, username: 'suspended_local') }
      let!(:suspended_remote)       { Fabricate(:account, suspended: true, domain: 'example.org', username: 'suspended_remote') }
      let!(:silenced_local)         { Fabricate(:account, silenced: true, username: 'silenced_local') }
      let!(:silenced_remote)        { Fabricate(:account, silenced: true, domain: 'example.org', username: 'silenced_remote') }
      let!(:unconfirmed)            { Fabricate(:user, confirmed_at: nil).account }
      let!(:unapproved)             { Fabricate(:user, approved: false).account }
      let!(:unconfirmed_unapproved) { Fabricate(:user, confirmed_at: nil, approved: false).account }
      let!(:local_account)          { Fabricate(:account, username: 'local_account') }
      let!(:remote_account)         { Fabricate(:account, domain: 'example.org', username: 'remote_account') }

      before do
        # Accounts get automatically-approved depending on settings, so ensure they aren't approved
        unapproved.user.update(approved: false)
        unconfirmed_unapproved.user.update(approved: false)
      end

      it 'returns every usable non-suspended account' do
        expect(described_class.searchable).to contain_exactly(silenced_local, silenced_remote, local_account, remote_account)
        expect(described_class.searchable).to_not include(suspended_local, suspended_remote, unconfirmed, unapproved)
      end

      it 'does not mess with previously-applied scopes' do
        expect(described_class.where.not(id: remote_account.id).searchable).to contain_exactly(silenced_local, silenced_remote, local_account)
      end
    end
  end

  context 'when is local' do
    it 'generates keys' do
      account = described_class.create!(domain: nil, username: 'user_without_keys')

      expect(account)
        .to be_private_key
        .and be_public_key
      expect(account.keypair)
        .to be_private
        .and be_public
    end
  end

  context 'when is remote' do
    it 'does not generate keys' do
      key = OpenSSL::PKey::RSA.new(1024).public_key
      account = described_class.create!(domain: 'remote', uri: 'https://remote/actor', username: 'remote_user_with_public', public_key: key.to_pem)
      expect(account.keypair.params).to eq key.params
    end

    it 'normalizes domain' do
      account = described_class.create!(domain: 'にゃん', uri: 'https://xn--r9j5b5b/actor', username: 'remote_user_with_idn_domain')
      expect(account.domain).to eq 'xn--r9j5b5b'
    end
  end

  include_examples 'AccountAvatar', :account
  include_examples 'AccountHeader', :account

  describe '#increment_count!' do
    subject { Fabricate(:account) }

    it 'increments the count in multi-threaded an environment when account_stat is not yet initialized' do
      subject

      multi_threaded_execution(15) do
        described_class.find(subject.id).increment_count!(:followers_count)
      end

      expect(subject.reload.followers_count).to eq 15
    end
  end
end
