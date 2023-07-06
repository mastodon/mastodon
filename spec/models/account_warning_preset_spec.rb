# frozen_string_literal: true

require 'rails_helper'

describe AccountWarningPreset do
  describe 'alphabetical' do
    let(:first) { Fabricate(:account_warning_preset, title: 'aaa', text: 'aaa') }
    let(:second) { Fabricate(:account_warning_preset, title: 'bbb', text: 'aaa') }
    let(:third) { Fabricate(:account_warning_preset, title: 'bbb', text: 'bbb') }

    it 'returns records in order of title and text' do
      results = described_class.alphabetic

      expect(results).to eq([first, second, third])
    end
  end
end
