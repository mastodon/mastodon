# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import do
  let(:account) { Fabricate(:account) }
  let(:type) { 'following' }
  let(:data) { attachment_fixture('imports.txt') }

  describe 'validations' do
    it 'has a valid parameters' do
      import = Import.create(account: account, type: type, data: data)
      expect(import).to be_valid
    end

    it 'is invalid without an type' do
      import = Import.create(account: account, data: data)
      expect(import).to model_have_error_on_field(:type)
    end

    it 'is invalid without a data' do
      import = Import.create(account: account, type: type)
      expect(import).to model_have_error_on_field(:data)
    end
  end
end
