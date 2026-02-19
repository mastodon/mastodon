# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dispute Appeals' do
  let(:user) { Fabricate(:user) }
  let!(:admin) { Fabricate(:admin_user) }

  before { sign_in user }

  describe 'Submitting an appeal', :inline_jobs do
    let(:strike) { Fabricate(:account_warning, target_account: user.account) }

    it 'Submits the appeal and notifies admins' do
      visit disputes_strike_path(strike)

      # Invalid with missing attribute
      fill_in 'appeal_text', with: ''
      emails = capture_emails do
        expect { submit_form }
          .to_not change(Appeal, :count)
      end
      expect(emails)
        .to be_empty
      expect(page)
        .to have_content(/can't be blank/)

      # Valid with text
      fill_in 'appeal_text', with: 'It wasnt me this time!'
      emails = capture_emails do
        expect { submit_form }
          .to change(Appeal, :count).by(1)
      end
      expect(emails)
        .to contain_exactly(
          have_attributes(
            to: contain_exactly(admin.email),
            subject: eq(new_appeal_subject)
          )
        )
      expect(page)
        .to have_content(I18n.t('disputes.strikes.appealed_msg'))
    end

    def new_appeal_subject
      I18n.t('admin_mailer.new_appeal.subject', username: user.account.acct, instance: Rails.configuration.x.local_domain)
    end

    def submit_form
      click_on I18n.t('disputes.strikes.appeals.submit')
    end
  end
end
