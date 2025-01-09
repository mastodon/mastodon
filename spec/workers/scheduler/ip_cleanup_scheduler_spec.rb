# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::IpCleanupScheduler do
  let(:worker) { described_class.new }

  describe '#perform' do
    context 'with IP-related data past retention times' do
      let!(:future_ip_block) { Fabricate :ip_block, expires_at: 1.week.from_now }
      let!(:old_ip_block) { Fabricate :ip_block, expires_at: 1.week.ago }
      let!(:session_past_retention) { Fabricate :session_activation, ip: '10.0.0.0', updated_at: 18.months.ago }
      let!(:inactive_user) { Fabricate :user, current_sign_in_at: 18.months.ago, sign_up_ip: '10.0.0.0' }
      let!(:old_login_activity) { Fabricate :login_activity, created_at: 18.months.ago }
      let!(:old_token) { Fabricate :access_token, last_used_at: 18.months.ago, last_used_ip: '10.0.0.0' }

      before { stub_const 'Scheduler::IpCleanupScheduler::SESSION_RETENTION_PERIOD', 10.years.to_i.seconds }

      it 'deletes the expired block' do
        expect { worker.perform }
          .to_not raise_error
        expect { old_ip_block.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
        expect { old_login_activity.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
        expect(session_past_retention.reload.ip)
          .to be_nil
        expect(inactive_user.reload.sign_up_ip)
          .to be_nil
        expect(old_token.reload.last_used_ip)
          .to be_nil
        expect(future_ip_block.reload)
          .to be_present
      end
    end

    context 'with old session data' do
      let!(:new_activation) { Fabricate :session_activation, updated_at: 1.week.ago }
      let!(:old_activation) { Fabricate :session_activation, updated_at: 1.month.ago }

      before { stub_const 'Scheduler::IpCleanupScheduler::SESSION_RETENTION_PERIOD', 10.days.to_i.seconds }

      it 'clears old sessions' do
        expect { worker.perform }
          .to_not raise_error

        expect { old_activation.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
        expect(new_activation.reload)
          .to be_present
      end
    end
  end
end
