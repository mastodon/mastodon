# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status do
  subject { Fabricate(:status, account: alice) }

  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }
  let(:other) { Fabricate(:status, account: bob, text: 'Skulls for the skull god! The enemy\'s gates are sideways!') }

  describe '#local?' do
    it 'returns true when no remote URI is set' do
      expect(subject.local?).to be true
    end

    it 'returns false if a remote URI is set' do
      alice.update(domain: 'example.com')
      subject.save
      expect(subject.local?).to be false
    end

    it 'returns true if a URI is set and `local` is true' do
      subject.update(uri: 'example.com', local: true)
      expect(subject.local?).to be true
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
    context 'when destroyed?' do
      it 'returns :delete' do
        subject.destroy!
        expect(subject.verb).to be :delete
      end
    end

    context 'when not destroyed?' do
      context 'when reblog?' do
        it 'returns :share' do
          subject.reblog = other
          expect(subject.verb).to be :share
        end
      end

      context 'when not reblog?' do
        it 'returns :post' do
          subject.reblog = nil
          expect(subject.verb).to be :post
        end
      end
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

  describe '#hidden?' do
    context 'when private_visibility?' do
      it 'returns true' do
        subject.visibility = :private
        expect(subject.hidden?).to be true
      end
    end

    context 'when direct_visibility?' do
      it 'returns true' do
        subject.visibility = :direct
        expect(subject.hidden?).to be true
      end
    end

    context 'when public_visibility?' do
      it 'returns false' do
        subject.visibility = :public
        expect(subject.hidden?).to be false
      end
    end

    context 'when unlisted_visibility?' do
      it 'returns false' do
        subject.visibility = :unlisted
        expect(subject.hidden?).to be false
      end
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

    it 'is decremented when reblog is removed' do
      reblog = Fabricate(:status, account: bob, reblog: subject)
      expect(subject.reblogs_count).to eq 1
      reblog.destroy
      expect(subject.reblogs_count).to eq 0
    end

    it 'does not fail when original is deleted before reblog' do
      reblog = Fabricate(:status, account: bob, reblog: subject)
      expect(subject.reblogs_count).to eq 1
      expect { subject.destroy }.to_not raise_error
      expect(Status.find_by(id: reblog.id)).to be_nil
    end
  end

  describe '#replies_count' do
    it 'is the number of replies' do
      reply = Fabricate(:status, account: bob, thread: subject)
      expect(subject.replies_count).to eq 1
    end

    it 'is decremented when reply is removed' do
      reply = Fabricate(:status, account: bob, thread: subject)
      expect(subject.replies_count).to eq 1
      reply.destroy
      expect(subject.replies_count).to eq 0
    end
  end

  describe '#favourites_count' do
    it 'is the number of favorites' do
      Fabricate(:favourite, account: bob, status: subject)
      Fabricate(:favourite, account: alice, status: subject)

      expect(subject.favourites_count).to eq 2
    end

    it 'is decremented when favourite is removed' do
      favourite = Fabricate(:favourite, account: bob, status: subject)
      expect(subject.favourites_count).to eq 1
      favourite.destroy
      expect(subject.favourites_count).to eq 0
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

  describe 'on create' do
    subject { Status.new }

    let(:local_account) { Fabricate(:account, username: 'local', domain: nil) }
    let(:remote_account) { Fabricate(:account, username: 'remote', domain: 'example.com') }

    describe 'on a status that ends with the local-only emoji' do
      before do
        subject.text = "A toot #{subject.local_only_emoji}"
      end

      context 'when the status originates from this instance' do
        before do
          subject.account = local_account
        end

        it 'is marked local-only' do
          subject.save!

          expect(subject).to be_local_only
        end
      end

      context 'when the status is remote' do
        before do
          subject.account = remote_account
        end

        it 'is not marked local-only' do
          subject.save!

          expect(subject).to_not be_local_only
        end
      end
    end
  end

  describe '.mutes_map' do
    subject { Status.mutes_map([status.conversation.id], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    it 'contains true value' do
      account.mute_conversation!(status.conversation)
      expect(subject[status.conversation.id]).to be true
    end
  end

  describe '.favourites_map' do
    subject { Status.favourites_map([status], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    it 'contains true value' do
      Fabricate(:favourite, status: status, account: account)
      expect(subject[status.id]).to be true
    end
  end

  describe '.reblogs_map' do
    subject { Status.reblogs_map([status], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    it 'contains true value' do
      Fabricate(:status, account: account, reblog: status)
      expect(subject[status.id]).to be true
    end
  end

  describe '.as_direct_timeline' do
    subject(:results) { Status.as_direct_timeline(account) }

    let(:account) { Fabricate(:account) }
    let(:followed) { Fabricate(:account) }
    let(:not_followed) { Fabricate(:account) }

    let!(:self_public_status) { Fabricate(:status, account: account, visibility: :public) }
    let!(:self_direct_status) { Fabricate(:status, account: account, visibility: :direct) }
    let!(:followed_public_status) { Fabricate(:status, account: followed, visibility: :public) }
    let!(:followed_direct_status) { Fabricate(:status, account: followed, visibility: :direct) }
    let!(:not_followed_direct_status) { Fabricate(:status, account: not_followed, visibility: :direct) }

    before do
      account.follow!(followed)
    end

    it 'does not include public statuses from self' do
      expect(results).to_not include(self_public_status)
    end

    it 'includes direct statuses from self' do
      expect(results).to include(self_direct_status)
    end

    it 'does not include public statuses from followed' do
      expect(results).to_not include(followed_public_status)
    end

    it 'does not include direct statuses not mentioning recipient from followed' do
      expect(results).to_not include(followed_direct_status)
    end

    it 'does not include direct statuses not mentioning recipient from non-followed' do
      expect(results).to_not include(not_followed_direct_status)
    end

    it 'includes direct statuses mentioning recipient from followed' do
      Fabricate(:mention, account: account, status: followed_direct_status)
      results2 = Status.as_direct_timeline(account)
      expect(results2).to include(followed_direct_status)
    end

    it 'includes direct statuses mentioning recipient from non-followed' do
      Fabricate(:mention, account: account, status: not_followed_direct_status)
      results2 = Status.as_direct_timeline(account)
      expect(results2).to include(not_followed_direct_status)
    end
  end

  describe '.tagged_with' do
    let(:tag1)     { Fabricate(:tag) }
    let(:tag2)     { Fabricate(:tag) }
    let(:tag3)     { Fabricate(:tag) }
    let!(:status1) { Fabricate(:status, tags: [tag1]) }
    let!(:status2) { Fabricate(:status, tags: [tag2]) }
    let!(:status3) { Fabricate(:status, tags: [tag3]) }
    let!(:status4) { Fabricate(:status, tags: []) }
    let!(:status5) { Fabricate(:status, tags: [tag1, tag2, tag3]) }

    context 'when given one tag' do
      it 'returns the expected statuses' do
        expect(Status.tagged_with([tag1.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status1.id, status5.id)
        expect(Status.tagged_with([tag2.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status2.id, status5.id)
        expect(Status.tagged_with([tag3.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status3.id, status5.id)
      end
    end

    context 'when given multiple tags' do
      it 'returns the expected statuses' do
        expect(Status.tagged_with([tag1.id, tag2.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status1.id, status2.id, status5.id)
        expect(Status.tagged_with([tag1.id, tag3.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status1.id, status3.id, status5.id)
        expect(Status.tagged_with([tag2.id, tag3.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status2.id, status3.id, status5.id)
      end
    end
  end

  describe '.tagged_with_all' do
    let(:tag1)     { Fabricate(:tag) }
    let(:tag2)     { Fabricate(:tag) }
    let(:tag3)     { Fabricate(:tag) }
    let!(:status1) { Fabricate(:status, tags: [tag1]) }
    let!(:status2) { Fabricate(:status, tags: [tag2]) }
    let!(:status3) { Fabricate(:status, tags: [tag3]) }
    let!(:status4) { Fabricate(:status, tags: []) }
    let!(:status5) { Fabricate(:status, tags: [tag1, tag2]) }

    context 'when given one tag' do
      it 'returns the expected statuses' do
        expect(Status.tagged_with_all([tag1.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status1.id, status5.id)
        expect(Status.tagged_with_all([tag2.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status2.id, status5.id)
        expect(Status.tagged_with_all([tag3.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status3.id)
      end
    end

    context 'when given multiple tags' do
      it 'returns the expected statuses' do
        expect(Status.tagged_with_all([tag1.id, tag2.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status5.id)
        expect(Status.tagged_with_all([tag1.id, tag3.id]).reorder(:id).pluck(:id).uniq).to eq []
        expect(Status.tagged_with_all([tag2.id, tag3.id]).reorder(:id).pluck(:id).uniq).to eq []
      end
    end
  end

  describe '.tagged_with_none' do
    let(:tag1)     { Fabricate(:tag) }
    let(:tag2)     { Fabricate(:tag) }
    let(:tag3)     { Fabricate(:tag) }
    let!(:status1) { Fabricate(:status, tags: [tag1]) }
    let!(:status2) { Fabricate(:status, tags: [tag2]) }
    let!(:status3) { Fabricate(:status, tags: [tag3]) }
    let!(:status4) { Fabricate(:status, tags: []) }
    let!(:status5) { Fabricate(:status, tags: [tag1, tag2, tag3]) }

    context 'when given one tag' do
      it 'returns the expected statuses' do
        expect(Status.tagged_with_none([tag1.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status2.id, status3.id, status4.id)
        expect(Status.tagged_with_none([tag2.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status1.id, status3.id, status4.id)
        expect(Status.tagged_with_none([tag3.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status1.id, status2.id, status4.id)
      end
    end

    context 'when given multiple tags' do
      it 'returns the expected statuses' do
        expect(Status.tagged_with_none([tag1.id, tag2.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status3.id, status4.id)
        expect(Status.tagged_with_none([tag1.id, tag3.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status2.id, status4.id)
        expect(Status.tagged_with_none([tag2.id, tag3.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status1.id, status4.id)
      end
    end
  end

  describe 'before_validation' do
    it 'sets account being replied to correctly over intermediary nodes' do
      first_status = Fabricate(:status, account: bob)
      intermediary = Fabricate(:status, thread: first_status, account: alice)
      final        = Fabricate(:status, thread: intermediary, account: alice)

      expect(final.in_reply_to_account_id).to eq bob.id
    end

    it 'creates new conversation for stand-alone status' do
      expect(Status.create(account: alice, text: 'First').conversation_id).to_not be_nil
    end

    it 'keeps conversation of parent node' do
      parent = Fabricate(:status, text: 'First')
      expect(Status.create(account: alice, thread: parent, text: 'Response').conversation_id).to eq parent.conversation_id
    end

    it 'sets `local` to true for status by local account' do
      expect(Status.create(account: alice, text: 'foo').local).to be true
    end

    it 'sets `local` to false for status by remote account' do
      alice.update(domain: 'example.com')
      expect(Status.create(account: alice, text: 'foo').local).to be false
    end
  end

  describe 'validation' do
    it 'disallow empty uri for remote status' do
      alice.update(domain: 'example.com')
      status = Fabricate.build(:status, uri: '', account: alice)
      expect(status).to model_have_error_on_field(:uri)
    end
  end

  describe 'after_create' do
    it 'saves ActivityPub uri as uri for local status' do
      status = Status.create(account: alice, text: 'foo')
      status.reload
      expect(status.uri).to start_with('https://')
    end
  end
end
