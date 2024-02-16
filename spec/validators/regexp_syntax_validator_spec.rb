# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegexpSyntaxValidator do
  let(:record_class) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :text

      validates :text, regexp_syntax: true
    end
  end

  let(:record) { record_class.new }

  describe '#validate_each' do
    context 'with a nil value' do
      it 'does not add errors' do
        record.text = nil

        expect(record).to be_valid
        expect(record.errors).to be_empty
      end
    end

    context 'with a blank' do
      it 'does not add errors' do
        record.text = ''

        expect(record).to be_valid
        expect(record.errors).to be_empty
      end
    end

    context 'with valid regexp' do
      it 'does not add errors' do
        record.text = 'spam|https://foo.bar'

        expect(record).to be_valid
        expect(record.errors).to be_empty
      end
    end

    context 'with more lines than limit' do
      it 'adds an error' do
        record.text = '('

        expect(record).to_not be_valid
        expect(record.errors.where(:text)).to_not be_empty
      end
    end
  end
end
