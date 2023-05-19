# frozen_string_literal: true

require 'rails_helper'

describe ExtendedDescription do
  describe '.current' do
    context 'with the default values' do
      it 'makes a new instance' do
        record = described_class.current

        expect(record.text).to be_nil
        expect(record.updated_at).to be_nil
      end
    end

    context 'with a custom setting value' do
      before do
        setting = instance_double(Setting, value: 'Extended text', updated_at: 10.days.ago)
        allow(Setting).to receive(:find_by).with(var: 'site_extended_description').and_return(setting)
      end

      it 'has the privacy text' do
        record = described_class.current

        expect(record.text).to eq('Extended text')
      end
    end
  end
end
