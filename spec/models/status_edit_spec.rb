# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusEdit do
  describe '#reblog?' do
    it 'returns false' do
      record = described_class.new

      expect(record).to_not be_a_reblog
    end
  end

  describe StatusEdit::PreservedMediaAttachment do
    subject { described_class.new(media_attachment: Fabricate(:media_attachment), description: '') }

    it { is_expected.to delegate_method(:status_id).to(:media_attachment) }
  end
end
