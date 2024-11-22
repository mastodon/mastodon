# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LanguageValidator do
  let(:record_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :locale

      validates :locale, language: true
    end
  end
  let(:record) { record_class.new }

  describe '#validate_each' do
    context 'with a nil value' do
      it 'does not add errors' do
        record.locale = nil

        expect(record).to be_valid
        expect(record.errors).to be_empty
      end
    end

    context 'with an array of values' do
      it 'does not add errors with array of existing locales' do
        record.locale = %w(en fr)

        expect(record).to be_valid
        expect(record.errors).to be_empty
      end

      it 'adds errors with array having some non-existing locales' do
        record.locale = %w(en fr missing)

        expect(record).to_not be_valid
        expect(record.errors.first.attribute).to eq(:locale)
        expect(record.errors.first.type).to eq(:invalid)
      end
    end

    context 'with a locale string' do
      it 'does not add errors when string is an existing locale' do
        record.locale = 'en'

        expect(record).to be_valid
        expect(record.errors).to be_empty
      end

      it 'adds errors when string is non-existing locale' do
        record.locale = 'missing'

        expect(record).to_not be_valid
        expect(record.errors.first.attribute).to eq(:locale)
        expect(record.errors.first.type).to eq(:invalid)
      end
    end
  end
end
