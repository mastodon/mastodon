# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacuum::InvitesVacuum do
  subject { described_class.new(retention_period, retention_max_uses) }

  let(:retention_period) { 7.days }
  let(:retention_max_uses) { 10 }

  let(:user) { Fabricate(:user) }

  describe '#perform' do
    let!(:invite_unlimited) { Fabricate(:invite, user: user, max_uses: nil, created_at: 10.days.ago, expires_at: nil) }
    let!(:invite_huge_max_uses) { Fabricate(:invite, max_uses: 100, created_at: 10.days.ago, expires_at: nil) }
    let!(:invite_small_max_uses) { Fabricate(:invite, max_uses: 2, created_at: 10.days.ago, expires_at: nil) }
    let!(:invite_will_expires_later) { Fabricate(:invite, max_uses: nil, created_at: 1.hour.ago, expires_at: 1.hour.from_now) }

    before do
      subject.perform
    end

    it 'expires unlimited invitation link' do
      expect(invite_unlimited.reload.expired?).to be true
    end

    it 'expires invitation link that have huge max uses' do
      expect(invite_huge_max_uses.reload.expired?).to be true
    end

    it 'does not expires invitation link that have small max uses' do
      expect(invite_small_max_uses.reload.expired?).to be false
    end

    it 'expires invitation link that will expire' do
      expect(invite_will_expires_later.reload.expired?).to be false
    end
  end
end
