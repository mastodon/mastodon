require 'rails_helper'

RSpec.describe Account, type: :model do
  subject { Fabricate(:account, username: 'alice') }

  context do
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
      expect(subject.local?).to be true
    end

    it 'returns false when the account is on a different domain' do
      subject.domain = 'foreign.tld'
      expect(subject.local?).to be false
    end
  end

  describe 'Local domain user methods' do
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
      expect(subject.acct).to eql 'alice'
    end

    it 'returns username@domain for foreign users' do
      subject.domain = 'foreign.tld'
      expect(subject.acct).to eql 'alice@foreign.tld'
    end
  end

  describe '#subscribed?' do
    it 'returns false when no subscription expiration information is present' do
      expect(subject.subscribed?).to be false
    end

    it 'returns true when subscription expiration has been set' do
      subject.subscription_expires_at = 30.days.from_now
      expect(subject.subscribed?).to be true
    end
  end

  describe '#keypair' do
    it 'returns an RSA key pair' do
      expect(subject.keypair).to be_instance_of OpenSSL::PKey::RSA
    end
  end

  describe '#subscription' do
    it 'returns an OStatus subscription' do
      expect(subject.subscription('')).to be_instance_of OStatus2::Subscription
    end
  end

  describe '#object_type' do
    it 'is always a person' do
      expect(subject.object_type).to be :person
    end
  end

  describe '#favourited?' do
    let(:original_status) do
      author = Fabricate(:account, username: 'original')
      Fabricate(:status, account: author)
    end

    context 'when the status is a reblog of another status' do
      let(:original_reblog) do
        author = Fabricate(:account, username: 'original_reblogger')
        Fabricate(:status, reblog: original_status, account: author)
      end

      it 'is is true when this account has favourited it' do
        Fabricate(:favourite, status: original_reblog, account: subject)

        expect(subject.favourited?(original_status)).to eq true
      end

      it 'is false when this account has not favourited it' do
        expect(subject.favourited?(original_status)).to eq false
      end
    end

    context 'when the status is an original status' do
      it 'is is true when this account has favourited it' do
        Fabricate(:favourite, status: original_status, account: subject)

        expect(subject.favourited?(original_status)).to eq true
      end

      it 'is false when this account has not favourited it' do
        expect(subject.favourited?(original_status)).to eq false
      end
    end
  end

  describe '#reblogged?' do
    let(:original_status) do
      author = Fabricate(:account, username: 'original')
      Fabricate(:status, account: author)
    end

    context 'when the status is a reblog of another status'do
      let(:original_reblog) do
        author = Fabricate(:account, username: 'original_reblogger')
        Fabricate(:status, reblog: original_status, account: author)
      end

      it 'is true when this account has reblogged it' do
        Fabricate(:status, reblog: original_reblog, account: subject)

        expect(subject.reblogged?(original_reblog)).to eq true
      end

      it 'is false when this account has not reblogged it' do
        expect(subject.reblogged?(original_reblog)).to eq false
      end
    end

    context 'when the status is an original status' do
      it 'is true when this account has reblogged it' do
        Fabricate(:status, reblog: original_status, account: subject)

        expect(subject.reblogged?(original_status)).to eq true
      end

      it 'is false when this account has not reblogged it' do
        expect(subject.reblogged?(original_status)).to eq false
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
      expect(results).to include(block.target_account.id)
      expect(results).to include(mute.target_account.id)
      expect(results).to include(block_by.account.id)
    end
  end

  describe '.search_for' do
    before do
      @match = Fabricate(
        :account,
        display_name: "Display Name",
        username: "username",
        domain: "example.com"
      )
      _missing = Fabricate(
        :account,
        display_name: "Missing",
        username: "missing",
        domain: "missing.com"
      )
    end

    it 'finds accounts with matching display_name' do
      results = Account.search_for("display")
      expect(results).to eq [@match]
    end

    it 'finds accounts with matching username' do
      results = Account.search_for("username")
      expect(results).to eq [@match]
    end

    it 'finds accounts with matching domain' do
      results = Account.search_for("example")
      expect(results).to eq [@match]
    end

    it 'ranks multiple matches higher' do
      account = Fabricate(
        :account,
        username: "username",
        display_name: "username"
      )
      results = Account.search_for("username")
      expect(results).to eq [account, @match]
    end
  end

  describe '.advanced_search_for' do
    it 'ranks followed accounts higher' do
      account = Fabricate(:account)
      match = Fabricate(:account, username: "Matching")
      followed_match = Fabricate(:account, username: "Matcher")
      Fabricate(:follow, account: account, target_account: followed_match)

      results = Account.advanced_search_for("match", account)
      expect(results).to eq [followed_match, match]
      expect(results.first.rank).to be > results.last.rank
    end
  end

  describe '.triadic_closures' do
    subject { described_class.triadic_closures(me) }

    let!(:me) { Fabricate(:account) }
    let!(:friend) { Fabricate(:account) }
    let!(:friends_friend) { Fabricate(:account) }
    let!(:both_follow) { Fabricate(:account) }

    before do
      me.follow!(friend)
      friend.follow!(friends_friend)

      me.follow!(both_follow)
      friend.follow!(both_follow)
    end

    it 'finds accounts you dont follow which are followed by accounts you do follow' do
      is_expected.to eq [friends_friend]
    end

    context 'when you block account' do
      before do
        me.block!(friends_friend)
      end

      it 'rejects blocked accounts' do
        is_expected.to be_empty
      end
    end

    context 'when you mute account' do
      before do
        me.mute!(friends_friend)
      end

      it 'rejects muted accounts' do
        is_expected.to be_empty
      end
    end
  end

  describe '.following_map' do
    it 'returns an hash' do
      expect(Account.following_map([], 1)).to be_a Hash
    end
  end

  describe '.followed_by_map' do
    it 'returns an hash' do
      expect(Account.followed_by_map([], 1)).to be_a Hash
    end
  end

  describe '.blocking_map' do
    it 'returns an hash' do
      expect(Account.blocking_map([], 1)).to be_a Hash
    end
  end

  describe '.requested_map' do
    it 'returns an hash' do
      expect(Account.requested_map([], 1)).to be_a Hash
    end
  end

  describe 'MENTION_RE' do
    subject { Account::MENTION_RE }

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

    xit 'does not match URL querystring' do
      expect(subject.match('https://example.com/?x=@alice')).to be_nil
    end
  end

  describe 'validations' do
    it 'has a valid fabricator' do
      account = Fabricate.build(:account)
      account.valid?
      expect(account).to be_valid
    end

    it 'is invalid without a username' do
      account = Fabricate.build(:account, username: nil)
      account.valid?
      expect(account).to model_have_error_on_field(:username)
    end

    it 'is invalid if the username already exists' do
      account_1 = Fabricate(:account, username: 'the_doctor')
      account_2 = Fabricate.build(:account, username: 'the_doctor')
      account_2.valid?
      expect(account_2).to model_have_error_on_field(:username)
    end

    it 'is invalid if the username is reserved' do
      account = Fabricate.build(:account, username: 'support')
      account.valid?
      expect(account).to model_have_error_on_field(:username)
    end

    context 'when is local' do
      it 'is invalid if the username doesn\'t only contains letters, numbers and underscores' do
        account = Fabricate.build(:account, username: 'the-doctor')
        account.valid?
        expect(account).to model_have_error_on_field(:username)
      end

      it 'is invalid if the username is longer then 30 characters' do
        account = Fabricate.build(:account, username: Faker::Lorem.characters(31))
        account.valid?
        expect(account).to model_have_error_on_field(:username)
      end
    end
  end

  describe 'scopes' do
    describe 'remote' do
      it 'returns an array of accounts who have a domain' do
        account_1 = Fabricate(:account, domain: nil)
        account_2 = Fabricate(:account, domain: 'example.com')
        expect(Account.remote).to match_array([account_2])
      end
    end

    describe 'by_domain_accounts' do
      it 'returns accounts grouped by domain sorted by accounts' do
        2.times { Fabricate(:account, domain: 'example.com') }
        Fabricate(:account, domain: 'example2.com')

        results = Account.by_domain_accounts
        expect(results.length).to eq 2
        expect(results.first.domain).to eq 'example.com'
        expect(results.first.accounts_count).to eq 2
        expect(results.last.domain).to eq 'example2.com'
        expect(results.last.accounts_count).to eq 1
      end
    end

    describe 'local' do
      it 'returns an array of accounts who do not have a domain' do
        account_1 = Fabricate(:account, domain: nil)
        account_2 = Fabricate(:account, domain: 'example.com')
        expect(Account.local).to match_array([account_1])
      end
    end

    describe 'silenced' do
      it 'returns an array of accounts who are silenced' do
        account_1 = Fabricate(:account, silenced: true)
        account_2 = Fabricate(:account, silenced: false)
        expect(Account.silenced).to match_array([account_1])
      end
    end

    describe 'suspended' do
      it 'returns an array of accounts who are suspended' do
        account_1 = Fabricate(:account, suspended: true)
        account_2 = Fabricate(:account, suspended: false)
        expect(Account.suspended).to match_array([account_1])
      end
    end
  end

  describe 'static avatars' do
    describe 'when GIF' do
      it 'creates a png static style' do
        subject.avatar = attachment_fixture('avatar.gif')
        subject.save

        expect(subject.avatar_static_url).to_not eq subject.avatar_original_url
      end
    end

    describe 'when non-GIF' do
      it 'does not create extra static style' do
        subject.avatar = attachment_fixture('attachment.jpg')
        subject.save

        expect(subject.avatar_static_url).to eq subject.avatar_original_url
      end
    end
  end
end
