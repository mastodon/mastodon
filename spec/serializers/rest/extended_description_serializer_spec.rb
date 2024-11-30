# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::ExtendedDescriptionSerializer do
  default_datetime = DateTime.new(2024, 11, 28, 16, 20, 0)
  subject { serialized_record_json(record, described_class) }

  describe 'serialization' do
    context 'with text present' do
      let(:record) { ExtendedDescription.new text: 'Hello world', updated_at: default_datetime }

      it 'returns expected values' do
        expect(subject)
          .to include(
            'content' => eq(<<~HTML),
              <p>Hello world</p>
            HTML
            'updated_at' => eq('2024-11-28T16:20:00.000Z')
          )
      end
    end

    # Note: Unsure what to do here; it's not clear if the updated_at property
    # is actually a datetime, or if it's free text.

    context 'with text missing' do
      let(:record) { ExtendedDescription.new text: nil, updated_at: default_datetime }

      it 'returns expected values' do
        expect(subject)
          .to include(
            'content' => eq(''),
            'updated_at' => eq('2024-11-28T16:20:00.000Z')
          )
     end
    end
  end
end
