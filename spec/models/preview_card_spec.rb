# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewCard do
  describe 'validations' do
    describe 'urls' do
      it 'allows http schemes' do
        record = described_class.new(url: 'http://example.host/path')

        expect(record).to be_valid
      end

      it 'allows https schemes' do
        record = described_class.new(url: 'https://example.host/path')

        expect(record).to be_valid
      end

      it 'does not allow javascript: schemes' do
        record = described_class.new(url: 'javascript:alert()')

        expect(record).to_not be_valid
        expect(record).to model_have_error_on_field(:url)
      end
    end
  end
end
