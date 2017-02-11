require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }

  subject { Follow.new(account: alice, target_account: bob) }

  describe '#verb' do
    it 'is follow' do
      expect(subject.verb).to be :follow
    end
  end

  describe '#title' do
    it 'describes the follow' do
      expect(subject.title).to eql 'alice started following bob'
    end
  end

  describe '#content' do
    it 'is the same as the title' do
      expect(subject.content).to eql subject.title
    end
  end

  describe '#object_type' do
    it 'is an activity' do
      expect(subject.object_type).to be :activity
    end
  end

  describe '#target' do
    it 'is the person being followed' do
      expect(subject.target).to eq bob
    end
  end
end
