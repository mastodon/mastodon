# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DisputesHelper do
  describe 'strike_action_label' do
    it 'returns html describing the appeal' do
      adam = Account.new(username: 'Adam')
      becky = Account.new(username: 'Becky')
      strike = AccountWarning.new(account: adam, action: :suspend)
      appeal = Appeal.new(strike: strike, account: becky)

      expected = <<~OUTPUT.strip
        <span class="username">Adam</span> suspended <span class="target">Becky</span>'s account
      OUTPUT
      result = helper.strike_action_label(appeal)

      expect(result).to eq(expected)
    end
  end
end
