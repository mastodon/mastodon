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
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    before { appeal }

    it 'returns a page that lists details of appeals' do
      get :index

      expect(response)
        .to have_http_status(:success)

      expect(response.body)
        .to include("<span class=\"username\">#{strike.account.username}</span>")
        .and include("<span class=\"target\">#{appeal.account.username}</span>")
    end
  end

  describe 'POST #approve' do
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    before do
      post :approve, params: { id: appeal.id }
    end

    it 'unsuspends a suspended account and notifies the target account' do
      expect(target_account.reload)
        .to have_attributes(suspended?: false)

      expect(response)
        .to redirect_to(disputes_strike_path(appeal.strike))

      expect(UserMailer.deliveries)
        .to contain_exactly(
          have_attributes(
            to: contain_exactly(target_account.user.email),
            subject: eq(I18n.t('user_mailer.appeal_approved.subject', date: I18n.l(appeal.created_at)))
          )
        )
    end
  end

  describe 'POST #reject' do
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    before do
      post :reject, params: { id: appeal.id }
    end

    it 'redirects back to the strike page and notifies the target account' do
      expect(response)
        .to redirect_to(disputes_strike_path(appeal.strike))

      expect(UserMailer.deliveries)
        .to contain_exactly(
          have_attributes(
            to: contain_exactly(target_account.user.email),
            subject: eq(I18n.t('user_mailer.appeal_rejected.subject', date: I18n.l(appeal.created_at)))
          )
        )
    end
  end
end
