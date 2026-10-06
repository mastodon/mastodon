# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Disputes Appeals' do
  before do
    sign_in(user)

    target_account.suspend!
  end

  let(:user) { Fabricate(:admin_user) }
  let(:target_account) { Fabricate(:account) }
  let(:strike) { Fabricate(:account_warning, target_account: target_account, action: :suspend) }
  let!(:appeal) { Fabricate(:appeal, strike: strike, account: target_account) }

  describe 'Viewing the disputed appeals list' do
    it 'returns a page that lists details of appeals' do
      visit admin_disputes_appeals_path

      expect(page)
        .to have_css('span.username', text: strike.account.username)
        .and have_css('span.target', text: appeal.account.username)
    end
  end

  describe 'Approving an appeal' do
    it 'redirects back to the strike page and notifies target account about approved appeal', :inline_jobs do
      visit admin_disputes_strike_path(strike)

      expect { click_on I18n.t('disputes.strikes.approve_appeal') }
        .to send_email(to: target_account.user.email, subject: approve_subject)

      expect(page)
        .to have_title(strike_title)

      expect(target_account.reload)
        .to_not be_suspended
    end

    def approve_subject
      I18n.t('user_mailer.appeal_approved.subject', date: I18n.l(appeal.created_at))
    end
  end

  describe 'Rejecting an appeal' do
    it 'redirects back to the strike page and notifies target account about rejected appeal', :inline_jobs do
      visit admin_disputes_strike_path(strike)

      expect { click_on I18n.t('disputes.strikes.reject_appeal') }
        .to send_email(to: target_account.user.email, subject: reject_subject)

      expect(page)
        .to have_title(strike_title)

      expect(target_account.reload)
        .to be_suspended
    end

    def reject_subject
      I18n.t('user_mailer.appeal_rejected.subject', date: I18n.l(appeal.created_at))
    end
  end

  def strike_title
    I18n.t('disputes.strikes.title', action: I18n.t(strike.action, scope: 'disputes.strikes.title_actions'), date: I18n.l(strike.created_at.to_date))
  end
end
