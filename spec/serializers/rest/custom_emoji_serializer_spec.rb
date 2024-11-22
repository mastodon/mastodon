# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::CustomEmojiSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate.build :custom_emoji, id: 123, category: Fabricate(:custom_emoji_category, name: 'Category Name') }

  describe 'serialization' do
    it 'returns expected values' do
      expect(subject)
        .to include(
          'category' => be_a(String).and(eq('Category Name'))
        )
    end
  end
end
