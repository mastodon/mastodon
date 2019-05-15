# frozen_string_literal: true

require 'rails_helper'

describe UnblockDomainService, type: :service do
  subject { described_class.new }

  describe 'call' do
    before do
      @independently_suspended = Fabricate(:account, domain: 'example.com', suspended_at: 1.hour.ago)
      @independently_silenced = Fabricate(:account, domain: 'example.com', silenced_at: 1.hour.ago)
      @domain_block = Fabricate(:domain_block, domain: 'example.com')
      @silenced = Fabricate(:account, domain: 'example.com', silenced_at: @domain_block.created_at)
      @suspended = Fabricate(:account, domain: 'example.com', suspended_at: @domain_block.created_at)
    end

    it 'unsilences accounts and removes block' do
      @domain_block.update(severity: :silence)

      subject.call(@domain_block)
      expect_deleted_domain_block
      expect(@silenced.reload.silenced?).to be false
      expect(@suspended.reload.suspended?).to be true
      expect(@independently_suspended.reload.suspended?).to be true
      expect(@independently_silenced.reload.silenced?).to be true
    end

    it 'unsuspends accounts and removes block' do
      @domain_block.update(severity: :suspend)

      subject.call(@domain_block)
      expect_deleted_domain_block
      expect(@suspended.reload.suspended?).to be false
      expect(@silenced.reload.silenced?).to be true
      expect(@independently_suspended.reload.suspended?).to be true
      expect(@independently_silenced.reload.silenced?).to be true
    end
  end

  def expect_deleted_domain_block
    expect { @domain_block.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
