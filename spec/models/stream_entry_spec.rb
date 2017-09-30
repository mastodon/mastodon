require 'rails_helper'

RSpec.describe StreamEntry, type: :model do
  let(:alice)     { Fabricate(:account, username: 'alice') }
  let(:bob)       { Fabricate(:account, username: 'bob') }
  let(:status)    { Fabricate(:status, account: alice) }
  let(:reblog)    { Fabricate(:status, account: bob, reblog: status) }
  let(:reply)     { Fabricate(:status, account: bob, thread: status) }

  describe '#targeted?' do
    it 'returns true for a reblog' do
      expect(reblog.stream_entry.targeted?).to be true
    end

    it 'returns false otherwise' do
      expect(status.stream_entry.targeted?).to be false
    end
  end

  describe '#threaded?' do
    it 'returns true for a reply' do
      expect(reply.stream_entry.threaded?).to be true
    end

    it 'returns false otherwise' do
      expect(status.stream_entry.threaded?).to be false
    end
  end

  describe 'delegated methods' do
    context 'with a nil status' do
      subject { described_class.new(status: nil) }

      it 'returns nil for target' do
        expect(subject.target).to be_nil
      end

      it 'returns nil for title' do
        expect(subject.title).to be_nil
      end

      it 'returns nil for content' do
        expect(subject.content).to be_nil
      end

      it 'returns nil for thread' do
        expect(subject.thread).to be_nil
      end
    end

    context 'with a real status' do
      let(:original) { Fabricate(:status, text: 'Test status') }
      let(:status) { Fabricate(:status, reblog: original, thread: original) }
      subject { described_class.new(status: status) }

      it 'delegates target' do
        expect(status.target).not_to be_nil
        expect(subject.target).to eq(status.target)
      end

      it 'delegates title' do
        expect(status.title).not_to be_nil
        expect(subject.title).to eq(status.title)
      end

      it 'delegates content' do
        expect(status.content).not_to be_nil
        expect(subject.content).to eq(status.content)
      end

      it 'delegates thread' do
        expect(status.thread).not_to be_nil
        expect(subject.thread).to eq(status.thread)
      end
    end
  end
end
