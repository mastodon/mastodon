# frozen_string_literal: true

require 'rails_helper'

describe OneTimeKey do
  describe 'validations' do
    context 'with an invalid signature' do
      let(:one_time_key) { Fabricate.build(:one_time_key, signature: 'wrong!') }

      it 'is invalid' do
        expect(one_time_key).to_not be_valid
      end
    end
  end
end
