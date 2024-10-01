# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewCard do
  describe 'file size limit', :attachment_processing do
    it 'is set differently whether vips is enabled or not' do
      expect(described_class::LIMIT).to eq(Rails.configuration.x.use_vips ? 8.megabytes : 2.megabytes)
    end
  end

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
