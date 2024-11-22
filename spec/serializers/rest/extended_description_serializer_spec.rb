# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::ExtendedDescriptionSerializer do
  subject { serialized_record_json(record, described_class) }

  describe 'serialization' do
    context 'with text present' do
      let(:record) { ExtendedDescription.new text: 'Hello world', updated_at: Date.new(2024, 1, 1) }

      it 'returns expected values' do
        expect(subject)
          .to include(
            'content' => eq(<<~HTML),
              <p>Hello world</p>
            HTML
            'updated_at' => eq('2024-01-01')
          )
      end
    end

    context 'with text missing' do
      let(:record) { ExtendedDescription.new text: nil, updated_at: Date.new(2024, 1, 1) }

      it 'returns expected values' do
        expect(subject)
          .to include(
            'content' => eq(''),
            'updated_at' => eq('2024-01-01')
          )
      end
    end
  end
end
