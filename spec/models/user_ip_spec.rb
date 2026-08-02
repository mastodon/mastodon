# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserIp do
  describe 'Scopes' do
    describe '.by_latest_used' do
      let!(:user) { Fabricate :user, sign_up_ip: '192.168.0.1', created_at: 15.days.ago }
      let!(:other_user) { Fabricate :user, sign_up_ip: '10.0.10.0', created_at: 10.days.ago }

      it 'returns records ordered by most recent usage' do
        expect(described_class.by_latest_used)
          .to eq([other_user.ips.last, user.ips.last])
      end
    end

    describe '.contained_by' do
      let!(:user) { Fabricate :user, sign_up_ip: '192.168.0.1' }
      let!(:other_user) { Fabricate :user, sign_up_ip: '10.0.10.0' }

      it 'returns records ordered by rank' do
        expect(described_class.contained_by('192.168.0.0/24'))
          .to include(user.ips.last)
          .and not_include(other_user.ips.last)
      end
    end
  end
end
