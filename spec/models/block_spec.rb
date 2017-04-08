require 'rails_helper'

RSpec.describe Block, type: :model do
  describe 'validations' do
    it 'has a valid fabricator' do
      block = Fabricate.build(:block)
      expect(block).to be_valid
    end

    it 'is invalid without an account' do
      block = Fabricate.build(:block, account: nil)
      block.valid?
      expect(block).to model_have_error_on_field(:account)
    end

    it 'is invalid without a target_account' do
      block = Fabricate.build(:block, target_account: nil)
      block.valid?
      expect(block).to model_have_error_on_field(:target_account)
    end
  end
end
