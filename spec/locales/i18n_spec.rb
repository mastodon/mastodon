# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'I18n' do
  describe 'Pluralizing locale translations' do
    subject { I18n.t('generic.validation_errors', count: 1) }

    context 'with the `en` locale which has `one` and `other` plural values' do
      around do |example|
        I18n.with_locale(:en) do
          example.run
        end
      end

      it 'translates to `en` correctly and without error' do
        expect { subject }.to_not raise_error
        expect(subject).to match(/the error below/)
      end
    end

    context 'with the `my` locale which has only `other` plural value' do
      around do |example|
        I18n.with_locale(:my) do
          example.run
        end
      end

      it 'translates to `my` correctly and without error' do
        expect { subject }.to_not raise_error
        expect(subject).to match(/1/)
      end
    end
  end
end
