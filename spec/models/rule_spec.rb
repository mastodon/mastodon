# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rule do
  describe 'scopes' do
    describe 'ordered' do
      let(:deleted_rule) { Fabricate(:rule, deleted_at: 10.days.ago) }
      let(:first_rule) { Fabricate(:rule, deleted_at: nil, priority: 1) }
      let(:last_rule) { Fabricate(:rule, deleted_at: nil, priority: 10) }

      it 'finds the correct records' do
        results = described_class.ordered

        expect(results).to eq([first_rule, last_rule])
      end
    end
  end

  describe '#move!' do
    let!(:first_rule) { Fabricate(:rule, text: 'foo') }
    let!(:second_rule) { Fabricate(:rule, text: 'bar') }
    let!(:third_rule) { Fabricate(:rule, text: 'baz') }

    it 'moves the rules as expected' do
      expect { first_rule.move!(+1) }
        .to change { described_class.ordered.pluck(:text) }.from(%w(foo bar baz)).to(%w(bar foo baz))

      expect { first_rule.move!(-1) }
        .to change { described_class.ordered.pluck(:text) }.from(%w(bar foo baz)).to(%w(foo bar baz))

      expect { third_rule.move!(-1) }
        .to change { described_class.ordered.pluck(:text) }.from(%w(foo bar baz)).to(%w(foo baz bar))

      expect { second_rule.move!(-1) }
        .to change { described_class.ordered.pluck(:text) }.from(%w(foo baz bar)).to(%w(foo bar baz))
    end
  end

  describe '#translation_for' do
    let!(:rule) { Fabricate(:rule, text: 'This is a rule', hint: 'This is an explanation of the rule') }
    let!(:translation) { Fabricate(:rule_translation, rule: rule, text: 'Ceci est une règle', hint: 'Ceci est une explication de la règle', language: 'fr') }

    it 'returns the expected translation, including fallbacks' do
      expect(rule.translation_for(:en)).to have_attributes(text: rule.text, hint: rule.hint)
      expect(rule.translation_for(:fr)).to have_attributes(text: translation.text, hint: translation.hint)
      expect(rule.translation_for(:'fr-CA')).to have_attributes(text: translation.text, hint: translation.hint)
    end
  end
end
