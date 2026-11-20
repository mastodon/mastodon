# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Report Actions' do
  describe 'POST /admin/reports/:report_id/actions' do
    subject { post admin_report_actions_path(report), params: action_params.merge(warning_params) }

    let(:user) { Fabricate(:admin_user) }
    let(:target_account) { Fabricate(:account) }
    let(:statuses) { Fabricate.times(2, :status, account: target_account) }
    let(:report) { Fabricate(:report, target_account: target_account, status_ids: statuses.map(&:id)) }
    let(:warning_params) { { text: 'Please follow the server rules' } }

    before do
      Fabricate(:media_attachment, account: target_account, status: statuses.first)
      sign_in user
    end

    shared_examples 'a supported action' do |action|
      let(:moderation_action) { action }

      it "processes the #{action} action and redirects to reports" do
        expect { subject }
          .to change { report.reload.action_taken? }.from(false).to(true)
          .and(change { target_account.strikes.count }.by(1))

        expect(target_account.strikes.last.text)
          .to eq(warning_params.fetch(:text, ''))
        expect(response)
          .to redirect_to(admin_reports_path)
      end
    end

    shared_examples 'supported actions' do
      it_behaves_like 'a supported action', 'suspend'
      it_behaves_like 'a supported action', 'silence'
      it_behaves_like 'a supported action', 'delete'
      it_behaves_like 'a supported action', 'mark_as_sensitive'
    end

    shared_examples 'an unknown action' do
      let(:moderation_action) { 'invalid_action' }

      it 'redirects to the report without resolving it or recording a strike' do
        subject

        expect(response)
          .to redirect_to(admin_report_path(report))
        expect(report.reload)
          .to_not be_action_taken
        expect(target_account.strikes)
          .to be_empty
      end
    end

    context 'with action as submit button' do
      let(:action_params) { { moderation_action => '' } }

      it_behaves_like 'supported actions'
      it_behaves_like 'an unknown action'

      context 'when text is unset' do
        let(:warning_params) { {} }

        it_behaves_like 'supported actions'
      end
    end

    context 'with moderation action as an extra field' do
      let(:action_params) { { moderation_action: moderation_action } }

      it_behaves_like 'an unknown action'

      context 'when text is unset' do
        let(:warning_params) { {} }

        it_behaves_like 'supported actions'
      end
    end
  end
end
