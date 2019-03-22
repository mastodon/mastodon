# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountTagStat, type: :model do
  key = 'accounts_count'
  let(:account_tag_stat) { Fabricate(:tag).account_tag_stat }

  describe '#increment_count!' do
    it 'calls #update' do
      args = { key => account_tag_stat.public_send(key) + 1 }
      expect(account_tag_stat).to receive(:update).with(args)
      account_tag_stat.increment_count!(key)
    end

    it 'increments value by 1' do
      expect do
        account_tag_stat.increment_count!(key)
      end.to change { account_tag_stat.accounts_count }.by(1)
    end
  end

  describe '#decrement_count!' do
    it 'calls #update' do
      args = { key => [account_tag_stat.public_send(key) - 1, 0].max }
      expect(account_tag_stat).to receive(:update).with(args)
      account_tag_stat.decrement_count!(key)
    end

    it 'decrements value by 1' do
      account_tag_stat.update(key => 1)

      expect do
        account_tag_stat.decrement_count!(key)
      end.to change { account_tag_stat.accounts_count }.by(-1)
    end
  end
end
