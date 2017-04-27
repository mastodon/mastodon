require 'rails_helper'

RSpec.describe Status, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }
  let(:other) { Fabricate(:status, account: bob, text: 'Skulls for the skull god! The enemy\'s gates are sideways!')}

  subject { Fabricate(:status, account: alice) }

  describe '#local?' do
    it 'returns true when no remote URI is set' do
      expect(subject.local?).to be true
    end

    it 'returns false if a remote URI is set' do
      subject.uri = 'a'
      expect(subject.local?).to be false
    end
  end

  describe '#reblog?' do
    it 'returns true when the status reblogs another status' do
      subject.reblog = other
      expect(subject.reblog?).to be true
    end

    it 'returns false if the status is self-contained' do
      expect(subject.reblog?).to be false
    end
  end

  describe '#reply?' do
    it 'returns true if the status references another' do
      subject.thread = other
      expect(subject.reply?).to be true
    end

    it 'returns false if the status is self-contained' do
      expect(subject.reply?).to be false
    end
  end

  describe '#verb' do
    it 'is always post' do
      expect(subject.verb).to be :post
    end
  end

  describe '#object_type' do
    it 'is note when the status is self-contained' do
      expect(subject.object_type).to be :note
    end

    it 'is comment when the status replies to another' do
      subject.thread = other
      expect(subject.object_type).to be :comment
    end
  end

  describe '#title' do
    it 'is a shorter version of the content' do
      expect(subject.title).to be_a String
    end
  end

  describe '#content' do
    it 'returns the text of the status if it is not a reblog' do
      expect(subject.content).to eql subject.text
    end

    it 'returns the text of the reblogged status' do
      subject.reblog = other
      expect(subject.content).to eql other.text
    end
  end

  describe '#target' do
    it 'returns nil if the status is self-contained' do
      expect(subject.target).to be_nil
    end

    it 'returns nil if the status is a reply' do
      subject.thread = other
      expect(subject.target).to be_nil
    end

    it 'returns the reblogged status' do
      subject.reblog = other
      expect(subject.target).to eq other
    end
  end

  describe '#reblogs_count' do
    it 'is the number of reblogs' do
      Fabricate(:status, account: bob, reblog: subject)
      Fabricate(:status, account: alice, reblog: subject)

      expect(subject.reblogs_count).to eq 2
    end
  end

  describe '#favourites_count' do
    it 'is the number of favorites' do
      Fabricate(:favourite, account: bob, status: subject)
      Fabricate(:favourite, account: alice, status: subject)

      expect(subject.favourites_count).to eq 2
    end
  end

  describe '#proper' do
    it 'is itself for original statuses' do
      expect(subject.proper).to eq subject
    end

    it 'is the source status for reblogs' do
      subject.reblog = other
      expect(subject.proper).to eq other
    end
  end

  describe '#permitted?' do
    pending
  end

  describe '#filter_from_context?' do
    pending
  end

  describe '.as_home_timeline' do
    before do
      account = Fabricate(:account)
      followed = Fabricate(:account)
      not_followed = Fabricate(:account)
      Fabricate(:follow, account: account, target_account: followed)

      @self_status = Fabricate(:status, account: account)
      @followed_status = Fabricate(:status, account: followed)
      @not_followed_status = Fabricate(:status, account: not_followed)

      @results = Status.as_home_timeline(account)
    end

    it 'includes statuses from self' do
      expect(@results).to include(@self_status)
    end

    it 'includes statuses from followed' do
      expect(@results).to include(@followed_status)
    end

    it 'does not include statuses from non-followed' do
      expect(@results).not_to include(@not_followed_status)
    end
  end

  describe '.as_public_timeline' do
    it 'only includes statuses with public visibility' do
      public_status = Fabricate(:status, visibility: :public)
      private_status = Fabricate(:status, visibility: :private)

      results = Status.as_public_timeline
      expect(results).to include(public_status)
      expect(results).not_to include(private_status)
    end

    it 'does not include replies' do
      status = Fabricate(:status)
      reply = Fabricate(:status, in_reply_to_id: status.id)

      results = Status.as_public_timeline
      expect(results).to include(status)
      expect(results).not_to include(reply)
    end

    it 'does not include boosts' do
      status = Fabricate(:status)
      boost = Fabricate(:status, reblog_of_id: status.id)

      results = Status.as_public_timeline
      expect(results).to include(status)
      expect(results).not_to include(boost)
    end

    it 'filters out silenced accounts' do
      account = Fabricate(:account)
      silenced_account = Fabricate(:account, silenced: true)
      status = Fabricate(:status, account: account)
      silenced_status = Fabricate(:status, account: silenced_account)

      results = Status.as_public_timeline
      expect(results).to include(status)
      expect(results).not_to include(silenced_status)
    end

    context 'with a local_only option set' do
      it 'does not include remote instances statuses' do
        local_account = Fabricate(:account, domain: nil)
        remote_account = Fabricate(:account, domain: 'test.com')
        local_status = Fabricate(:status, account: local_account)
        remote_status = Fabricate(:status, account: remote_account)

        results = Status.as_public_timeline(nil, true)
        expect(results).to include(local_status)
        expect(results).not_to include(remote_status)
      end
    end

    describe 'with an account passed in' do
      it 'excludes statuses from accounts blocked by the account'

      it 'excludes statuses from accounts who have blocked the account'

      it 'excludes statuses from accounts muted by the account'

      context 'where that account is silenced' do
        it 'includes statuses from other accounts that are silenced'
      end
    end
  end
end
