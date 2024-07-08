# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reports' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'write:reports' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'POST /api/v1/reports' do
    subject do
      post '/api/v1/reports', headers: headers, params: params
    end

    let!(:admin)         { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
    let(:status)         { Fabricate(:status) }
    let(:target_account) { status.account }
    let(:category)       { 'other' }
    let(:forward)        { nil }
    let(:rule_ids)       { nil }

    let(:params) do
      {
        status_ids: [status.id],
        account_id: target_account.id,
        comment: 'reasons',
        category: category,
        rule_ids: rule_ids,
        forward: forward,
      }
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:reports'

    it 'creates a report', :aggregate_failures, :inline_jobs do
      emails = capture_emails { subject }

      expect(response).to have_http_status(200)
      expect(body_as_json).to match(
        a_hash_including(
          status_ids: [status.id.to_s],
          category: category,
          comment: 'reasons'
        )
      )

      expect(target_account.targeted_reports).to_not be_empty
      expect(target_account.targeted_reports.first.comment).to eq 'reasons'

      expect(emails.size)
        .to eq(1)
      expect(emails.first)
        .to have_attributes(
          to: contain_exactly(admin.email),
          subject: eq(I18n.t('admin_mailer.new_report.subject', instance: Rails.configuration.x.local_domain, id: target_account.targeted_reports.first.id))
        )
    end

    context 'when a status does not belong to the reported account' do
      let(:target_account) { Fabricate(:account) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end

    context 'when a category is chosen' do
      let(:category) { 'spam' }

      it 'saves category' do
        subject

        expect(target_account.targeted_reports.first.spam?).to be true
      end
    end

    context 'when violated rules are chosen' do
      let(:rule)     { Fabricate(:rule) }
      let(:category) { 'violation' }
      let(:rule_ids) { [rule.id] }

      it 'saves category and rule_ids' do
        subject

        expect(target_account.targeted_reports.first.violation?).to be true
        expect(target_account.targeted_reports.first.rule_ids).to contain_exactly(rule.id)
      end
    end
  end
end
