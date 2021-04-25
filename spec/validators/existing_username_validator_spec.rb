# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExistingUsernameValidator, type: :validator do
  describe '#validate_each' do
    before do
      validator.validate_each(record, attribute, value)
    end

    let(:validator) { described_class.new(attributes: [attribute]) }
    let(:record)    { double(errors: errors) }
    let(:errors)    { double(add: nil) }
    let(:value)     { '' }
    let(:attribute) { {multiple: false} }

    context 'when single account' do
      let(:value)     { '@admin' }
      it 'not calls errors.add' do
        expect(errors).not_to have_received(:add).with(attribute, any_args)
      end
    end

    context 'when multiple accounts' do
      let(:value)     { '@admin,@test' }
      let(:attribute) { {multiple: true} }
      it 'not calls errors.add' do
        expect(errors).not_to have_received(:add).with(attribute, any_args)
      end
    end
  end
end
