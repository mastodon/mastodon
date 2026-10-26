# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/character_counter'

RSpec.describe Mastodon::CharacterCounter do
  subject { described_class.new }

  context 'when note is too long' do
    let(:too_long) { 'a' * 200 }

    it 'with countable note text' do
      expect(subject.countable_note_text(too_long)).to eq(too_long)
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(too_long)).to eq(too_long)
    end
  end

  context 'when note has space separated linkable URLs' do
    let(:text) { [starting_string, example_link].join(' ') }

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to eq([starting_string, url_placeholder].join(' '))
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to eq([starting_string, url_placeholder].join(' '))
    end
  end

  context 'when note has non-separated URLs' do
    let(:text) { [starting_string, example_link].join }

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to eq(text)
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to eq(text)
    end
  end

  context 'with multiline text and mentions and URL' do
    let(:text) do
      <<~TEXT
        great day here with @mause@bart

        https://maus.social/jolly-link
      TEXT
    end

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to include("great day here with @mause\n\n#{url_placeholder}\n")
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to include("great day here with @mause\n\n#{url_placeholder}\n")
    end
  end

  context 'with multi-byte emoji' do
    let(:text) { '✨' * 100 }

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to eq(text)
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to eq(text)
    end
  end

  context 'with ZWJ sequence emoji' do
    let(:text) { '🏳️‍⚧️' * 100 }

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to eq(text)
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to eq(text)
    end
  end

  context 'when text and content warning combine to exceed limit' do
    let(:text) { 'a' * 50 }

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to eq(text)
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to eq(text)
    end
  end

  context 'with long URLs' do
    let(:text) { "http://example.com/something#{'?valid=foo' * 10}" }

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to eq(url_placeholder)
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to eq(url_placeholder)
    end
  end

  context 'with excessively long URLs' do
    let(:text) { "http://example.com/something#{'?valid=foo' * 1000}" }

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to eq(text)
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to eq(text)
    end
  end

  context 'when remote account usernames cause limit excess' do
    let(:text) { ('a' * 75) + " @alice@#{'b' * 30}.com" }

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to eq("#{'a' * 75} @alice")
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to eq("#{'a' * 75} @alice")
    end
  end

  context 'when remote usernames are attached to long domains' do
    let(:text) { "@alice@#{'b' * Extractor::MAX_DOMAIN_LENGTH * 2}.com" }

    it 'with countable note text' do
      expect(subject.countable_note_text(text)).to eq('@alice')
    end

    it 'with countable status text' do
      expect(subject.countable_status_text(text)).to eq(text)
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

  def url_placeholder
    @url_placeholder = Mastodon::CharacterCounter::URL_PLACEHOLDER
  end
end
