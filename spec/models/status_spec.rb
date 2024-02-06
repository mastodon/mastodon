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
      expect(described_class.find_by(id: reblog.id)).to be_nil
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

  describe '.mutes_map' do
    subject { described_class.mutes_map([status.conversation.id], account) }

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
    subject { described_class.favourites_map([status], account) }

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
    subject { described_class.reblogs_map([status], account) }

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

  describe '.tagged_with' do
    let(:tag_cats) { Fabricate(:tag, name: 'cats') }
    let(:tag_dogs) { Fabricate(:tag, name: 'dogs') }
    let(:tag_zebras) { Fabricate(:tag, name: 'zebras') }
    let!(:status_with_tag_cats) { Fabricate(:status, tags: [tag_cats]) }
    let!(:status_with_tag_dogs) { Fabricate(:status, tags: [tag_dogs]) }
    let!(:status_tagged_with_zebras) { Fabricate(:status, tags: [tag_zebras]) }
    let!(:status_without_tags) { Fabricate(:status, tags: []) }
    let!(:status_with_all_tags) { Fabricate(:status, tags: [tag_cats, tag_dogs, tag_zebras]) }

    context 'when given one tag' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with([tag_cats.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_cats.id, status_with_all_tags.id)
        expect(described_class.tagged_with([tag_dogs.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_dogs.id, status_with_all_tags.id)
        expect(described_class.tagged_with([tag_zebras.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_tagged_with_zebras.id, status_with_all_tags.id)
      end
    end

    context 'when given multiple tags' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with([tag_cats.id, tag_dogs.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_cats.id, status_with_tag_dogs.id, status_with_all_tags.id)
        expect(described_class.tagged_with([tag_cats.id, tag_zebras.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_cats.id, status_tagged_with_zebras.id, status_with_all_tags.id)
        expect(described_class.tagged_with([tag_dogs.id, tag_zebras.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_dogs.id, status_tagged_with_zebras.id, status_with_all_tags.id)
      end
    end
  end

  describe '.tagged_with_all' do
    let(:tag_cats) { Fabricate(:tag, name: 'cats') }
    let(:tag_dogs) { Fabricate(:tag, name: 'dogs') }
    let(:tag_zebras) { Fabricate(:tag, name: 'zebras') }
    let!(:status_with_tag_cats) { Fabricate(:status, tags: [tag_cats]) }
    let!(:status_with_tag_dogs) { Fabricate(:status, tags: [tag_dogs]) }
    let!(:status_tagged_with_zebras) { Fabricate(:status, tags: [tag_zebras]) }
    let!(:status_without_tags) { Fabricate(:status, tags: []) }
    let!(:status_with_all_tags) { Fabricate(:status, tags: [tag_cats, tag_dogs]) }

    context 'when given one tag' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with_all([tag_cats.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_cats.id, status_with_all_tags.id)
        expect(described_class.tagged_with_all([tag_dogs.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_dogs.id, status_with_all_tags.id)
        expect(described_class.tagged_with_all([tag_zebras.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_tagged_with_zebras.id)
      end
    end

    context 'when given multiple tags' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with_all([tag_cats.id, tag_dogs.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_all_tags.id)
        expect(described_class.tagged_with_all([tag_cats.id, tag_zebras.id]).reorder(:id).pluck(:id).uniq).to eq []
        expect(described_class.tagged_with_all([tag_dogs.id, tag_zebras.id]).reorder(:id).pluck(:id).uniq).to eq []
      end
    end
  end

  describe '.tagged_with_none' do
    let(:tag_cats) { Fabricate(:tag, name: 'cats') }
    let(:tag_dogs) { Fabricate(:tag, name: 'dogs') }
    let(:tag_zebras) { Fabricate(:tag, name: 'zebras') }
    let!(:status_with_tag_cats) { Fabricate(:status, tags: [tag_cats]) }
    let!(:status_with_tag_dogs) { Fabricate(:status, tags: [tag_dogs]) }
    let!(:status_tagged_with_zebras) { Fabricate(:status, tags: [tag_zebras]) }
    let!(:status_without_tags) { Fabricate(:status, tags: []) }
    let!(:status_with_all_tags) { Fabricate(:status, tags: [tag_cats, tag_dogs, tag_zebras]) }

    context 'when given one tag' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with_none([tag_cats.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_dogs.id, status_tagged_with_zebras.id, status_without_tags.id)
        expect(described_class.tagged_with_none([tag_dogs.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_cats.id, status_tagged_with_zebras.id, status_without_tags.id)
        expect(described_class.tagged_with_none([tag_zebras.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_cats.id, status_with_tag_dogs.id, status_without_tags.id)
      end
    end

    context 'when given multiple tags' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with_none([tag_cats.id, tag_dogs.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_tagged_with_zebras.id, status_without_tags.id)
        expect(described_class.tagged_with_none([tag_cats.id, tag_zebras.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_dogs.id, status_without_tags.id)
        expect(described_class.tagged_with_none([tag_dogs.id, tag_zebras.id]).reorder(:id).pluck(:id).uniq).to contain_exactly(status_with_tag_cats.id, status_without_tags.id)
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
      expect(described_class.create(account: alice, text: 'First').conversation_id).to_not be_nil
    end

    it 'keeps conversation of parent node' do
      parent = Fabricate(:status, text: 'First')
      expect(described_class.create(account: alice, thread: parent, text: 'Response').conversation_id).to eq parent.conversation_id
    end

    it 'sets `local` to true for status by local account' do
      expect(described_class.create(account: alice, text: 'foo').local).to be true
    end

    it 'sets `local` to false for status by remote account' do
      alice.update(domain: 'example.com')
      expect(described_class.create(account: alice, text: 'foo').local).to be false
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
      status = described_class.create(account: alice, text: 'foo')
      status.reload
      expect(status.uri).to start_with('https://')
    end
  end
end
