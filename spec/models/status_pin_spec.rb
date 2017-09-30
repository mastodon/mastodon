require 'rails_helper'

RSpec.describe StatusPin, type: :model do
  describe 'validations' do
    it 'allows pins of own statuses' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account)

      expect(StatusPin.new(account: account, status: status).save).to be true
    end

    it 'does not allow pins of statuses by someone else' do
      account = Fabricate(:account)
      status  = Fabricate(:status)

      expect(StatusPin.new(account: account, status: status).save).to be false
    end

    it 'does not allow pins of reblogs' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account)
      reblog  = Fabricate(:status, reblog: status)

      expect(StatusPin.new(account: account, status: reblog).save).to be false
    end

    it 'does not allow pins of private statuses' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account, visibility: :private)

      expect(StatusPin.new(account: account, status: status).save).to be false
    end

    it 'does not allow pins of direct statuses' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account, visibility: :direct)

      expect(StatusPin.new(account: account, status: status).save).to be false
    end
  end
end
