# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnblockDomainService do
  subject { described_class.new }

  describe 'call' do
    let!(:independently_suspended) { Fabricate(:account, domain: 'example.com', suspended_at: 1.hour.ago) }
    let!(:independently_silenced) { Fabricate(:account, domain: 'example.com', silenced_at: 1.hour.ago) }
    let!(:domain_block) { Fabricate(:domain_block, domain: 'example.com') }
    let!(:silenced) { Fabricate(:account, domain: 'example.com', silenced_at: domain_block.created_at) }
    let!(:suspended) { Fabricate(:account, domain: 'example.com', suspended_at: domain_block.created_at) }

    context 'with severity of silence' do
      before { domain_block.update(severity: :silence) }

      it 'unsilences accounts and removes block' do
        subject.call(domain_block)

        expect_deleted_domain_block
        expect(silenced.reload.silenced?).to be false
        expect(suspended.reload.suspended?).to be true
        expect(independently_suspended.reload.suspended?).to be true
        expect(independently_silenced.reload.silenced?).to be true
      end
    end

    context 'with severity of suspend' do
      before { domain_block.update(severity: :suspend) }

      it 'unsuspends accounts and removes block' do
        subject.call(domain_block)

        expect_deleted_domain_block
        expect(suspended.reload.suspended?).to be false
        expect(silenced.reload.silenced?).to be false
        expect(independently_suspended.reload.suspended?).to be true
        expect(independently_silenced.reload.silenced?).to be true
      end
    end
  end

  def expect_deleted_domain_block
    expect { domain_block.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
