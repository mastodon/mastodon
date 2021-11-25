# frozen_string_literal: true

require 'rails_helper'

describe LanguagesHelper do
  describe 'the HUMAN_LOCALES constant' do
    it 'includes all I18n locales' do
      expect(described_class::HUMAN_LOCALES.keys).to include(*I18n.available_locales)
    end
  end

  describe 'human_locale' do
    it 'finds the human readable local description from a key' do
      expect(helper.human_locale(:en)).to eq('English')
    end
  end
end
