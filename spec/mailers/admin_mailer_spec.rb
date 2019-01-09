# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminMailer, type: :mailer do
  describe '.new_report' do
    let(:sender)    { Fabricate(:account, username: 'John', user: Fabricate(:user)) }
    let(:recipient) { Fabricate(:account, username: 'Mike', user: Fabricate(:user, locale: :en)) }
    let(:report)    { Fabricate(:report, account: sender, target_account: recipient) }
    let(:mail)      { described_class.new_report(recipient, report) }

    it 'renders the headers' do
      expect(mail.subject).to eq("New report for cb6e6126.ngrok.io (##{report.id})")
      expect(mail.to).to eq [recipient.user_email]
      expect(mail.from).to eq ['notifications@localhost']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to eq("Mike,\r\n\r\nJohn has reported Mike\r\n\r\nView: https://cb6e6126.ngrok.io/admin/reports/#{report.id}\r\n")
    end
  end
end
