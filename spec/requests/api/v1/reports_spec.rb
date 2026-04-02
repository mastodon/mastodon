# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reports' do
  include_context 'with API authentication', oauth_scopes: 'write:reports'

  describe 'POST /api/v1/reports' do
    subject do
      post '/api/v1/reports', headers: headers, params: params
    end

    let!(:admin)         { Fabricate(:admin_user) }
    let(:target_account) { Fabricate(:account) }
    let(:category)       { 'other' }
    let(:forward)        { nil }
    let(:rule_ids)       { nil }
    let(:status_ids)     { nil }
    let(:collection_ids) { nil }

    let(:params) do
      {
        status_ids:,
        collection_ids:,
        account_id: target_account.id,
        comment: 'reasons',
        category:,
        rule_ids:,
        forward:,
      }
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:reports'

    it 'creates a report', :aggregate_failures, :inline_jobs do
      emails = capture_emails { subject }

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to match(
        a_hash_including(
          category: category,
          comment: 'reasons'
        )
      )

      expect(target_account.targeted_reports).to_not be_empty
      expect(target_account.targeted_reports.first.comment).to eq 'reasons'
      expect(target_account.targeted_reports.first.application).to eq token.application

      expect(emails.size)
        .to eq(1)
      expect(emails.first)
        .to have_attributes(
          to: contain_exactly(admin.email),
          subject: eq(I18n.t('admin_mailer.new_report.subject', instance: Rails.configuration.x.local_domain, id: target_account.targeted_reports.first.id))
        )
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

    context 'with attached status' do
      let(:status) { Fabricate(:status, account: target_account) }
      let(:status_ids) { [status.id] }

      it 'creates a report including the status ids', :aggregate_failures, :inline_jobs do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to match(
          a_hash_including(
            status_ids: [status.id.to_s],
            category: category,
            comment: 'reasons'
          )
        )
      end

      context 'when a status does not belong to the reported account' do
        let(:status) { Fabricate(:status) }

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end

    context 'with attached collection', feature: :collections do
      let(:collection) { Fabricate(:collection, account: target_account) }
      let(:collection_ids) { [collection.id] }

      it 'creates a report including the collection ids', :aggregate_failures, :inline_jobs do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to match(
          a_hash_including(
            collection_ids: [collection.id.to_s],
            category: category,
            comment: 'reasons'
          )
        )
      end

      context 'when a collection does not belong to the reported account' do
        let(:collection) { Fabricate(:collection) }

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end
  end
end
