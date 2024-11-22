# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFilter do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:context) }

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
    describe 'context' do
      it { is_expected.to normalize(:context).from(['home', 'notifications', 'public    ', '']).to(%w(home notifications public)) }
    end
  end
end
