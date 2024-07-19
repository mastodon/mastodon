# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFilter do
  describe 'Validations' do
    it 'requires presence of title' do
      record = described_class.new(title: '')
      record.valid?

      expect(record).to model_have_error_on_field(:title)
    end

    it 'requires presence of context' do
      record = described_class.new(context: nil)
      record.valid?

      expect(record).to model_have_error_on_field(:context)
    end

    it 'requires non-empty of context' do
      record = described_class.new(context: [])
      record.valid?

      expect(record).to model_have_error_on_field(:context)
    end

    it 'requires valid context value' do
      record = described_class.new(context: ['invalid'])
      record.valid?

      expect(record).to model_have_error_on_field(:context)
    end
  end

  describe 'Normalizations' do
    it 'cleans up context values' do
      record = described_class.new(context: ['home', 'notifications', 'public    ', ''])

      expect(record.context).to eq(%w(home notifications public))
    end
  end
end
