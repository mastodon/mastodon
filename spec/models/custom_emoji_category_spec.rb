# frozen_string_literal: true

require 'rails_helper'

describe CustomEmojiCategory do
  describe 'validations' do
    it 'validates name presence' do
      record = described_class.new(name: nil)

      expect(record).to_not be_valid
      expect(record).to model_have_error_on_field(:name)
    end
  end
end
