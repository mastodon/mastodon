# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApproveAppealService do
  describe '#call' do
    context 'with an existing appeal' do
      let(:appeal) { Fabricate(:appeal) }
      let(:account) { Fabricate(:account) }

      it 'processes the appeal approval' do
        expect { subject.call(appeal, account) }
          .to mark_overruled
          .and record_approver
      end

      def mark_overruled
        change(appeal.strike, :overruled_at)
          .from(nil)
          .to(be > 1.minute.ago)
      end

      def record_approver
        change(appeal, :approved_by_account)
          .from(nil)
          .to(account)
      end
    end
  end
end
