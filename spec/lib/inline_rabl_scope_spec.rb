# frozen_string_literal: true

require 'rails_helper'

describe InlineRablScope do
  describe '#current_account' do
    it 'returns the given account' do
      account = Fabricate(:account)
      expect(InlineRablScope.new(account).current_account).to eq account
    end
  end

  describe '#current_user' do
    it 'returns nil if the given account is nil' do
      expect(InlineRablScope.new(nil).current_user).to eq nil
    end

    it 'returns user of account if the given account is not nil' do
      user = Fabricate(:user)
      expect(InlineRablScope.new(user.account).current_user).to eq user
    end
  end
end
