# frozen_string_literal: true

require 'rails_helper'

describe Marker do
  describe 'validations' do
    describe 'timeline' do
      it 'must be included in valid list' do
        record = described_class.new(timeline: 'not real timeline')

        expect(record).to_not be_valid
        expect(record).to model_have_error_on_field(:timeline)
      end
    end
  end
end
