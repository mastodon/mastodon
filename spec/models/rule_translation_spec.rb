# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RuleTranslation do
  describe '#possibly_stale?' do
    let!(:rule) { Fabricate(:rule) }
    let!(:translation) { Fabricate(:rule_translation, rule: rule) }

    context 'with a translation edited after the rule' do
      before do
        translation.touch
      end

      it 'returns false' do
        expect(translation.possibly_stale?).to be false
      end
    end

    context 'with a rule edited after the translation' do
      before do
        rule.touch
      end

      it 'returns true' do
        expect(translation.possibly_stale?).to be true
      end
    end
  end
end
