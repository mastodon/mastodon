# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Poll do
  describe 'validations' do
    context 'when valid' do
      let(:poll) { Fabricate.build(:poll) }

      it 'is valid with valid attributes' do
        expect(poll).to be_valid
      end
    end

    context 'when not valid' do
      let(:poll) { Fabricate.build(:poll, expires_at: nil) }

      it 'is invalid without an expire date' do
        poll.valid?
        expect(poll).to model_have_error_on_field(:expires_at)
      end
    end
  end
end
