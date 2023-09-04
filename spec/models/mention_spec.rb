# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mention do
  describe 'validations' do
    it 'is invalid without an account' do
      mention = Fabricate.build(:mention, account: nil)
      mention.valid?
      expect(mention).to model_have_error_on_field(:account)
    end

    it 'is invalid without a status' do
      mention = Fabricate.build(:mention, status: nil)
      mention.valid?
      expect(mention).to model_have_error_on_field(:status)
    end
  end
end
