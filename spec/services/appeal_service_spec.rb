# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppealService, :inline_jobs do
  describe '#call' do
    let!(:admin) { Fabricate(:admin_user) }

    context 'with an existing strike' do
      let(:strike) { Fabricate(:account_warning) }
      let(:text) { 'Appeal text' }

      it 'creates an appeal and notifies staff' do
        emails = capture_emails { subject.call(strike, text) }

        expect(Appeal.last)
          .to have_attributes(
            strike: strike,
            text: text,
            account: strike.target_account
          )

        expect(emails.size)
          .to eq(1)

        expect(emails.first)
          .to have_attributes(
            to: contain_exactly(admin.email),
            subject: eq(
              I18n.t(
                'admin_mailer.new_appeal.subject',
                username: strike.target_account.acct,
                instance: Rails.configuration.x.local_domain
              )
            )
          )
      end
    end
  end
end
