# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoteLengthValidator do
  subject { record_class.new }

  let(:record_class) do
    Class.new do
      include ActiveModel::Validations

      def self.name = 'Record'

      attr_accessor :note

      validates :note, note_length: { maximum: 100 }
    end
  end

  context 'when note is too long' do
    let(:too_long) { 'a' * 200 }

    it { is_expected.to_not allow_value(too_long).for(:note).with_message(too_long_message) }
  end

  context 'when note has space separated linkable URLs' do
    let(:text) { [starting_string, example_link].join(' ') }

    it { is_expected.to allow_value(text).for(:note) }
  end

  context 'when note has non-separated URLs' do
    let(:text) { [starting_string, example_link].join }

    it { is_expected.to_not allow_value(text).for(:note).with_message(too_long_message) }
  end

  context 'with multi-byte emoji' do
    let(:text) { '✨' * 100 }

    it { is_expected.to allow_value(text).for(:note) }
  end

  context 'with ZWJ sequence emoji' do
    let(:text) { '🏳️‍⚧️' * 100 }

    it { is_expected.to allow_value(text).for(:note) }
  end

  private

  def too_long_message
    I18n.t('statuses.over_character_limit', max: 100)
  end

  def starting_string
    'a' * 76
  end

  def example_link
    "http://#{'b' * 30}.com/example"
  end
end
