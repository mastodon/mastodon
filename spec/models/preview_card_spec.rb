# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewCard do
  describe 'file size limit', :attachment_processing do
    it 'is set differently whether vips is enabled or not' do
      expect(described_class::LIMIT).to eq(Rails.configuration.x.use_vips ? 8.megabytes : 2.megabytes)
    end
  end

  describe 'Validations' do
    describe 'url' do
      it { is_expected.to allow_values('http://example.host/path', 'https://example.host/path').for(:url) }
      it { is_expected.to_not allow_value('javascript:alert()').for(:url) }
    end
  end
end
