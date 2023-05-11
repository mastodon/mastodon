# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusPin do
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

    it 'does allow pins of direct statuses' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account, visibility: :private)

      expect(StatusPin.new(account: account, status: status).save).to be true
    end

    it 'does not allow pins of direct statuses' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account, visibility: :direct)

      expect(StatusPin.new(account: account, status: status).save).to be false
    end

    max_pins = 5
    it 'does not allow pins above the max' do
      account = Fabricate(:account)
      status = []

      (max_pins + 1).times do |i|
        status[i] = Fabricate(:status, account: account)
      end

      max_pins.times do |i|
        expect(StatusPin.new(account: account, status: status[i]).save).to be true
      end

      expect(StatusPin.new(account: account, status: status[max_pins]).save).to be false
    end

    it 'allows pins above the max for remote accounts' do
      account = Fabricate(:account, domain: 'remote.test', username: 'bob', url: 'https://remote.test/')
      status = []

      (max_pins + 1).times do |i|
        status[i] = Fabricate(:status, account: account)
      end

      max_pins.times do |i|
        expect(StatusPin.new(account: account, status: status[i]).save).to be true
      end

      expect(StatusPin.new(account: account, status: status[max_pins]).save).to be true
    end
  end
end
