# frozen_string_literal: true

require 'rails_helper'

RSpec.describe URLValidator, type: :validator do
  describe '#validate_each' do
    before do
      allow(validator).to receive(:compliant?).with(value) { compliant }
      validator.validate_each(record, attribute, value)
    end

    let(:validator) { described_class.new(attributes: [attribute]) }
    let(:record)    { double(errors: errors) }
    let(:errors)    { double(add: nil) }
    let(:value)     { '' }
    let(:attribute) { :foo }

    context 'unless compliant?' do
      let(:compliant) { false }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(attribute, I18n.t('applications.invalid_url'))
      end
    end

    context 'if compliant?' do
      let(:compliant) { true }

      it 'not calls errors.add' do
        expect(errors).not_to have_received(:add).with(attribute, any_args)
      end
    end
  end
end
