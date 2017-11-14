require 'rails_helper'

RSpec.describe StreamEntry, type: :model do
  let(:alice)     { Fabricate(:account, username: 'alice') }
  let(:bob)       { Fabricate(:account, username: 'bob') }
  let(:status)    { Fabricate(:status, account: alice) }
  let(:reblog)    { Fabricate(:status, account: bob, reblog: status) }
  let(:reply)     { Fabricate(:status, account: bob, thread: status) }
  let(:stream_entry) { Fabricate(:stream_entry, activity: reply) }

  describe '#object_type' do
    before do
      allow(stream_entry).to receive(:orphaned?).and_return(orphaned)
      allow(stream_entry).to receive(:targeted?).and_return(targeted)
    end

    context 'orphaned? is true' do
      let(:orphaned) { true }
      let(:targeted) { false }

      it 'returns :activity' do
        expect(stream_entry.object_type).to be :activity
      end
    end

    context 'targeted? is true' do
      let(:orphaned) { false }
      let(:targeted) { true }

      it 'returns :activity' do
        expect(stream_entry.object_type).to be :activity
      end
    end

    context 'orphaned? and targeted? are false' do
      let(:orphaned) { false }
      let(:targeted) { false }

      it 'calls status.object_type' do
        expect(stream_entry).to receive_message_chain(:status, :object_type)
        stream_entry.object_type
      end
    end
  end

  describe '#verb' do
    before do
      allow(stream_entry).to receive(:orphaned?).and_return(orphaned)
    end

    context 'orphaned? is true' do
      let(:orphaned) { true }

      it 'returns :delete' do
        expect(stream_entry.verb).to be :delete
      end
    end

    context 'orphaned? is false' do
      let(:orphaned) { false }

      it 'calls status.verb' do
        expect(stream_entry).to receive_message_chain(:status, :verb)
        stream_entry.verb
      end
    end
  end

  describe '#mentions' do
    before do
      allow(stream_entry).to receive(:orphaned?).and_return(orphaned)
    end

    context 'orphaned? is true' do
      let(:orphaned) { true }

      it 'returns []' do
        expect(stream_entry.mentions).to eq []
      end
    end

    context 'orphaned? is false' do
      let(:orphaned) { false }

      it 'calls status.mentions.map' do
        expect(stream_entry).to receive_message_chain(:status, :mentions, :map)
        stream_entry.mentions
      end
    end
  end

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
