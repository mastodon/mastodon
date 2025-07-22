# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountWarningPreset do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:text) }
  end

  describe '.alphabetical' do
    let(:first) { Fabricate(:account_warning_preset, title: 'aaa', text: 'aaa') }
    let(:second) { Fabricate(:account_warning_preset, title: 'bbb', text: 'aaa') }
    let(:third) { Fabricate(:account_warning_preset, title: 'bbb', text: 'bbb') }

    it 'returns records in order of title and text' do
      results = described_class.alphabetic

      expect(results).to eq([first, second, third])
    end
  end

  describe '#to_label' do
    subject { Fabricate.build(:account_warning_preset, title:, text:).to_label }

    let(:title) { nil }
    let(:text) { 'Preset text' }

    context 'when title is blank' do
      it { is_expected.to eq('Preset text') }
    end

    context 'when title is present' do
      let(:title) { 'Title' }

      it { is_expected.to eq('Title - Preset text') }
    end

    context 'when text is longer than limit' do
      let(:title) { 'Title' }

      before { stub_const('AccountWarningPreset::LABEL_TEXT_LENGTH', 10) }

      it { is_expected.to eq('Title - Preset ...') }
    end
  end
end
