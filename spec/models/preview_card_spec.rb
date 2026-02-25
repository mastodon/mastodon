# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewCard do
  describe 'Validations' do
    describe 'url' do
      it { is_expected.to allow_values('http://example.host/path', 'https://example.host/path').for(:url) }
      it { is_expected.to_not allow_value('javascript:alert()').for(:url) }
    end
  end
end
