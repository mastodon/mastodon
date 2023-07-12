# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ReportsController do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'POST #create' do
    let!(:admin) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    let(:scopes) { 'write:reports' }
    let(:status) { Fabricate(:status) }
    let(:target_account) { status.account }
    let(:category) { nil }
    let(:forward) { nil }
    let(:rule_ids) { nil }

    before do
      post :create, params: { status_ids: [status.id], account_id: target_account.id, comment: 'reasons', category: category, rule_ids: rule_ids, forward: forward }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'creates a report' do
      expect(target_account.targeted_reports).to_not be_empty
    end

    it 'saves comment' do
      expect(target_account.targeted_reports.first.comment).to eq 'reasons'
    end

    it 'sends e-mails to admins' do
      expect(ActionMailer::Base.deliveries.first.to).to eq([admin.email])
    end

    context 'when a status does not belong to the reported account' do
      let(:target_account) { Fabricate(:account) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when a category is chosen' do
      let(:category) { 'spam' }

      it 'saves category' do
        expect(target_account.targeted_reports.first.spam?).to be true
      end
    end

    context 'when violated rules are chosen' do
      let(:rule) { Fabricate(:rule) }
      let(:category) { 'violation' }
      let(:rule_ids) { [rule.id] }

      it 'saves category' do
        expect(target_account.targeted_reports.first.violation?).to be true
      end

      it 'saves rule_ids' do
        expect(target_account.targeted_reports.first.rule_ids).to contain_exactly(rule.id)
      end
    end
  end
end
