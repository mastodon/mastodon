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

  describe '#ping!' do
    pending
  end

  describe '#favourited?' do
    pending
  end

  describe '#reblogged?' do
    pending
  end

  describe '.find_local' do
    pending
  end

  describe '.find_remote' do
    pending
  end

  describe 'MENTION_RE' do
    subject { Account::MENTION_RE }

    it 'matches usernames in the middle of a sentence' do
      expect(subject.match('Hello to @alice from me')[1]).to eq 'alice'
    end

    it 'matches usernames in the beginning of status' do
      expect(subject.match('@alice Hey how are you?')[1]).to eq 'alice'
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
  end
end
