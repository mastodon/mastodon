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

  describe '#mentions' do
    before do
      bob # make sure the account exists
    end

    it 'is empty if the status is self-contained and does not mention anyone' do
      expect(subject.mentions).to be_empty
    end

    it 'returns mentioned accounts' do
      subject.text = 'Hello @bob!'
      expect(subject.mentions).to include bob
    end

    it 'returns account of the replied-to status' do
      subject.thread = other
      expect(subject.mentions).to include bob
    end

    it 'returns the account of the shared status' do
      subject.reblog = other
      expect(subject.mentions).to include bob
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
    pending
  end

  describe '#favourites_count' do
    pending
  end
end
