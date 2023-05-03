# frozen_string_literal: true

require 'rails_helper'

describe StatusEdit do
  describe '#reblog?' do
    it 'returns false' do
      record = described_class.new

      expect(record).to_not be_a_reblog
    end
  end
end
