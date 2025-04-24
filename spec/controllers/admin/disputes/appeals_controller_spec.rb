# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Disputes::AppealsController do
  render_views

  before do
    sign_in current_user, scope: :user

    target_account.suspend!
  end

  let(:target_account) { Fabricate(:account) }
  let(:strike) { Fabricate(:account_warning, target_account: target_account, action: :suspend) }
  let(:appeal) { Fabricate(:appeal, strike: strike, account: target_account) }

  describe 'GET #index' do
    let(:current_user) { Fabricate(:admin_user) }

    before { appeal }

    it 'returns a page that lists details of appeals' do
      get :index

      expect(response).to have_http_status(:success)
      expect(response.body).to include("<span class=\"username\">#{strike.account.username}</span>")
      expect(response.body).to include("<span class=\"target\">#{appeal.account.username}</span>")
    end
  end

  describe 'POST #approve' do
    subject { post :approve, params: { id: appeal.id } }

    let(:current_user) { Fabricate(:admin_user) }

    it 'redirects back to the strike page and notifies target account about approved appeal', :inline_jobs do
      emails = capture_emails { subject }

      expect(response)
        .to redirect_to(disputes_strike_path(appeal.strike))

      expect(target_account.reload)
        .to_not be_suspended

      expect(emails.size)
        .to eq(1)
      expect(emails.first)
        .to have_attributes(
          to: contain_exactly(target_account.user.email),
          subject: eq(I18n.t('user_mailer.appeal_approved.subject', date: I18n.l(appeal.created_at)))
        )
    end
  end

  describe 'POST #reject' do
    subject { post :reject, params: { id: appeal.id } }

    let(:current_user) { Fabricate(:admin_user) }

    it 'redirects back to the strike page and notifies target account about rejected appeal', :inline_jobs do
      emails = capture_emails { subject }

      expect(response)
        .to redirect_to(disputes_strike_path(appeal.strike))

      expect(emails.size)
        .to eq(1)

      expect(emails.first)
        .to have_attributes(
          to: contain_exactly(target_account.user.email),
          subject: eq(I18n.t('user_mailer.appeal_rejected.subject', date: I18n.l(appeal.created_at)))
        )
    end
  end
end
