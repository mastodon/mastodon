# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpamCheck do
  let!(:sender) { Fabricate(:account) }
  let!(:alice) { Fabricate(:account, username: 'alice') }
  let!(:bob) { Fabricate(:account, username: 'bob') }

  def status_with_html(text, options = {})
    status = PostStatusService.new.call(sender, { text: text }.merge(options))
    status.update_columns(text: Formatter.instance.format(status), local: false)
    status
  end

  describe '#hashable_text' do
    it 'removes mentions from HTML for remote statuses' do
      status = status_with_html('@alice Hello')
      expect(described_class.new(status).hashable_text).to eq 'hello'
    end

    it 'removes mentions from text for local statuses' do
      status = PostStatusService.new.call(alice, text: "Hey @#{sender.username}, how are you?")
      expect(described_class.new(status).hashable_text).to eq 'hey , how are you?'
    end
  end

  describe '#insufficient_data?' do
    it 'returns true when there is no text' do
      status = status_with_html('@alice')
      expect(described_class.new(status).insufficient_data?).to be true
    end

    it 'returns false when there is text' do
      status = status_with_html('@alice h')
      expect(described_class.new(status).insufficient_data?).to be false
    end
  end

  describe '#digest' do
    it 'returns a string' do
      status = status_with_html('@alice Hello world')
      expect(described_class.new(status).digest).to be_a String
    end
  end

  describe '#spam?' do
    it 'returns false for a unique status' do
      status = status_with_html('@alice Hello')
      expect(described_class.new(status).spam?).to be false
    end

    it 'returns false for different statuses to the same recipient' do
      status1 = status_with_html('@alice Hello')
      described_class.new(status1).remember!
      status2 = status_with_html('@alice Are you available to talk?')
      expect(described_class.new(status2).spam?).to be false
    end

    it 'returns false for statuses with different content warnings' do
      status1 = status_with_html('@alice Are you available to talk?')
      described_class.new(status1).remember!
      status2 = status_with_html('@alice Are you available to talk?', spoiler_text: 'This is a completely different matter than what I was talking about previously, I swear!')
      expect(described_class.new(status2).spam?).to be false
    end

    it 'returns false for different statuses to different recipients' do
      status1 = status_with_html('@alice How is it going?')
      described_class.new(status1).remember!
      status2 = status_with_html('@bob Are you okay?')
      expect(described_class.new(status2).spam?).to be false
    end

    it 'returns false for very short different statuses to different recipients' do
      status1 = status_with_html('@alice 🙄')
      described_class.new(status1).remember!
      status2 = status_with_html('@bob Huh?')
      expect(described_class.new(status2).spam?).to be false
    end

    it 'returns false for statuses with no text' do
      status1 = status_with_html('@alice')
      described_class.new(status1).remember!
      status2 = status_with_html('@bob')
      expect(described_class.new(status2).spam?).to be false
    end

    it 'returns true for duplicate statuses to the same recipient' do
      described_class::THRESHOLD.times do
        status1 = status_with_html('@alice Hello')
        described_class.new(status1).remember!
      end

      status2 = status_with_html('@alice Hello')
      expect(described_class.new(status2).spam?).to be true
    end

    it 'returns true for duplicate statuses to different recipients' do
      described_class::THRESHOLD.times do
        status1 = status_with_html('@alice Hello')
        described_class.new(status1).remember!
      end

      status2 = status_with_html('@bob Hello')
      expect(described_class.new(status2).spam?).to be true
    end

    it 'returns true for nearly identical statuses with random numbers' do
      source_text = 'Sodium, atomic number 11, was first isolated by Humphry Davy in 1807. A chemical component of salt, he named it Na in honor of the saltiest region on earth, North America.'

      described_class::THRESHOLD.times do
        status1 = status_with_html('@alice ' + source_text + ' 1234')
        described_class.new(status1).remember!
      end

      status2 = status_with_html('@bob ' + source_text + ' 9568')
      expect(described_class.new(status2).spam?).to be true
    end
  end

  describe '#skip?' do
    it 'returns true when the sender is already silenced' do
      status = status_with_html('@alice Hello')
      sender.silence!
      expect(described_class.new(status).skip?).to be true
    end

    it 'returns true when the mentioned person follows the sender' do
      status = status_with_html('@alice Hello')
      alice.follow!(sender)
      expect(described_class.new(status).skip?).to be true
    end

    it 'returns false when even one mentioned person doesn\'t follow the sender' do
      status = status_with_html('@alice @bob Hello')
      alice.follow!(sender)
      expect(described_class.new(status).skip?).to be false
    end

    it 'returns true when the sender is replying to a status that mentions the sender' do
      parent = PostStatusService.new.call(alice, text: "Hey @#{sender.username}, how are you?")
      status = status_with_html('@alice @bob Hello', thread: parent)
      expect(described_class.new(status).skip?).to be true
    end
  end

  describe '#remember!' do
    let(:status) { status_with_html('@alice') }
    let(:spam_check) { described_class.new(status) }
    let(:redis_key) { spam_check.send(:redis_key) }

    it 'remembers' do
      expect(Redis.current.exists(redis_key)).to be true
      spam_check.remember!
      expect(Redis.current.exists(redis_key)).to be true
    end
  end

  describe '#reset!' do
    let(:status) { status_with_html('@alice') }
    let(:spam_check) { described_class.new(status) }
    let(:redis_key) { spam_check.send(:redis_key) }

    before do
      spam_check.remember!
    end

    it 'resets' do
      expect(Redis.current.exists(redis_key)).to be true
      spam_check.reset!
      expect(Redis.current.exists(redis_key)).to be false
    end
  end

  describe '#flag!' do
    let!(:status1) { status_with_html('@alice General Kenobi you are a bold one') }
    let!(:status2) { status_with_html('@alice @bob General Kenobi, you are a bold one') }

    before do
      described_class.new(status1).remember!
      described_class.new(status2).flag!
    end

    it 'silences the account' do
      expect(sender.silenced?).to be true
    end

    it 'creates a report about the account' do
      expect(sender.targeted_reports.unresolved.count).to eq 1
    end

    it 'attaches both matching statuses to the report' do
      expect(sender.targeted_reports.first.status_ids).to include(status1.id, status2.id)
    end
  end
end
