# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterCounter do
  subject { described_class.new }

  context 'when note is too long' do
    let(:too_long) { 'a' * 200 }

    it do
      expect(subject.countable_note_text(too_long)).to eq(too_long)
    end
  end

  context 'when note has space separated linkable URLs' do
    let(:text) { [starting_string, example_link].join(' ') }

    it do
      expect(subject.countable_note_text(text)).to eq([starting_string, CharacterCounter::URL_PLACEHOLDER].join(' '))
    end
  end

  context 'when note has non-separated URLs' do
    let(:text) { [starting_string, example_link].join }

    it do
      expect(subject.countable_note_text(text)).to eq(text)
    end
  end

  context 'with mentions' do
    let(:text) { '@mause@bart ' * 15 }

    it do
      expect(subject.countable_note_text(text)).to eq('@mause ' * 15)
    end
  end

  context 'with multi-byte emoji' do
    let(:text) { '✨' * 100 }

    it do
      expect(subject.countable_note_text(text)).to eq(text)
    end
  end

  context 'with ZWJ sequence emoji' do
    let(:text) { '🏳️‍⚧️' * 100 }

    it do
      expect(subject.countable_note_text(text)).to eq(text)
    end
  end

  context 'when text and content warning combine to exceed limit' do
    let(:text) { 'a' * 50 }

    it do
      expect(subject.countable_text(text)).to eq(text)
    end
  end

  context 'when text has space separated linkable URLs' do
    let(:text) { [starting_string, example_link].join(' ') }

    it do
      expect(subject.countable_text(text)).to eq([starting_string, CharacterCounter::URL_PLACEHOLDER].join(' '))
    end
  end

  context 'when text has non-separated URLs' do
    let(:text) { [starting_string, example_link].join }

    it do
      expect(subject.countable_text(text)).to eq(text)
    end
  end

  context 'with long URLs' do
    let(:text) { "http://example.com/something#{'?valid=foo' * 10}" }

    it do
      expect(subject.countable_text(text)).to eq(CharacterCounter::URL_PLACEHOLDER)
    end
  end

  context 'with note long URLs' do
    let(:text) { "http://example.com/something#{'?valid=foo' * 10}" }

    it do
      expect(subject.countable_note_text(text)).to eq(CharacterCounter::URL_PLACEHOLDER)
    end
  end

  context 'with excessively long URLs' do
    let(:text) { "http://example.com/something#{'?valid=foo' * 1000}" }

    it do
      expect(subject.countable_text(text)).to eq(text)
    end
  end

  context 'with note excessively long URLs' do
    let(:text) { "http://example.com/something#{'?valid=foo' * 1000}" }

    it do
      expect(subject.countable_note_text(text)).to eq(text)
    end
  end

  context 'when remote account usernames cause limit excess' do
    let(:text) { ('a' * 75) + " @alice@#{'b' * 30}.com" }

    it do
      expect(subject.countable_text(text)).to eq("#{'a' * 75} @alice")
    end
  end

  context 'when remote usernames are attached to long domains' do
    let(:text) { "@alice@#{'b' * Extractor::MAX_DOMAIN_LENGTH * 2}.com" }

    it do
      expect(subject.countable_text(text)).to eq(text)
    end
  end

  context 'with special character strings' do
    let(:multibyte_emoji) { '✨' * 100 }
    let(:zwj_sequence) { '🏳️‍⚧️' * 100 }

    it do
      expect(subject.countable_text(multibyte_emoji)).to eq(multibyte_emoji)
      expect(subject.countable_text(zwj_sequence)).to eq(zwj_sequence)
    end
  end

  private

  def too_long_message
    I18n.t('errors.messages.too_long', count: 100)
  end

  def starting_string
    'a' * 76
  end

  def example_link
    "http://#{'b' * 30}.com/example"
  end
end
