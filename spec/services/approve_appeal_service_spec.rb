# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApproveAppealService do
  describe '#call' do
    let(:appeal) { Fabricate(:appeal) }
    let(:account) { Fabricate(:account) }

    it 'processes the appeal approval' do
      expect { subject.call(appeal, account) }
        .to mark_overruled
        .and record_approver
    end

    context 'with an appeal about then-deleted posts marked as sensitive by moderators' do
      let(:target_account) { Fabricate(:account) }
      let(:appeal) { Fabricate(:appeal, strike: strike, account: target_account) }
      let(:deleted_media) { Fabricate(:media_attachment, type: :video, status: Fabricate(:status, account: target_account), account: target_account) }
      let(:kept_media) { Fabricate(:media_attachment, type: :video, status: Fabricate(:status, account: target_account), account: target_account) }
      let(:strike) { Fabricate(:account_warning, target_account: target_account, action: :mark_statuses_as_sensitive, status_ids: [deleted_media.status.id, kept_media.status.id]) }

      before do
        target_account.unsuspend!
        deleted_media.status.discard!
      end

      it 'approves the appeal, marks the statuses as not sensitive and notifies target account about the approval', :inline_jobs do
        emails = capture_emails { subject.call(appeal, account) }

        expect(appeal.reload).to be_approved
        expect(strike.reload).to be_overruled

        expect(kept_media.status.reload).to_not be_sensitive

        expect(emails.size)
          .to eq(1)
        expect(emails.first)
          .to have_attributes(
            to: contain_exactly(target_account.user.email),
            subject: eq(I18n.t('user_mailer.appeal_approved.subject', date: I18n.l(appeal.created_at)))
          )
      end
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
