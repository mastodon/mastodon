require 'rails_helper'

RSpec.describe Favourite, type: :model do
  let(:alice)  { Fabricate(:account, username: 'alice') }
  let(:bob)    { Fabricate(:account, username: 'bob') }
  let(:status) { Fabricate(:status, account: bob) }

  subject { Favourite.new(account: alice, status: status) }

  describe '#verb' do
    it 'is always favorite' do
      expect(subject.verb).to be :favorite
    end
  end

  describe '#title' do
    it 'describes the favourite' do
      expect(subject.title).to eql 'alice favourited a status by bob'
    end
  end

  describe '#content' do
    it 'equals the title' do
      expect(subject.content).to eq subject.title
    end
  end

  describe '#object_type' do
    it 'is a note when the target is a note' do
      expect(subject.object_type).to be :note
    end

    it 'is a comment when the target is a comment' do
      status.in_reply_to_id = 2
      expect(subject.object_type).to be :comment
    end
  end

  describe '#target' do
    it 'is the status that was favourited' do
      expect(subject.target).to eq status
    end
  end

  describe '#thread' do
    it 'equals the target' do
      expect(subject.thread).to eq subject.target
    end
  end
end
