# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Favourite do
  let(:account) { Fabricate(:account) }

  context 'when status is a reblog' do
    let(:reblog) { Fabricate(:status, reblog: nil) }
    let(:status) { Fabricate(:status, reblog: reblog) }

    it 'invalidates if the reblogged status is already a favourite' do
      Favourite.create!(account: account, status: reblog)
      expect(Favourite.new(account: account, status: status).valid?).to be false
    end

    it 'replaces status with the reblogged one if it is a reblog' do
      favourite = Favourite.create!(account: account, status: status)
      expect(favourite.status).to eq reblog
    end
  end

  context 'when status is not a reblog' do
    let(:status) { Fabricate(:status, reblog: nil) }

    it 'saves with the specified status' do
      favourite = Favourite.create!(account: account, status: status)
      expect(favourite.status).to eq status
    end
  end
end
