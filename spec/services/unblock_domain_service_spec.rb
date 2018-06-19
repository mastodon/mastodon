# frozen_string_literal: true

require 'rails_helper'

describe UnblockDomainService, type: :service do
  subject { described_class.new }

  describe 'call' do
    before do
      @silenced = Fabricate(:account, domain: 'example.com', silenced: true)
      @suspended = Fabricate(:account, domain: 'example.com', suspended: true)
      @domain_block = Fabricate(:domain_block, domain: 'example.com')
    end

    context 'without retroactive' do
      it 'removes the domain block' do
        subject.call(@domain_block, false)
        expect_deleted_domain_block
      end
    end

    context 'with retroactive' do
      it 'unsilences accounts and removes block' do
        @domain_block.update(severity: :silence)

        subject.call(@domain_block, true)
        expect_deleted_domain_block
        expect(@silenced.reload.silenced).to be false
        expect(@suspended.reload.suspended).to be true
      end

      it 'unsuspends accounts and removes block' do
        @domain_block.update(severity: :suspend)

        subject.call(@domain_block, true)
        expect_deleted_domain_block
        expect(@suspended.reload.suspended).to be false
        expect(@silenced.reload.silenced).to be true
      end
    end
  end

  def expect_deleted_domain_block
    expect { @domain_block.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
