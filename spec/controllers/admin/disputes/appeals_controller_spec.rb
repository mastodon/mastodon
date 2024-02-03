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

      expect(response).to have_http_status(:success)
      expect(response.body).to include("<span class=\"username\">#{strike.account.username}</span>")
      expect(response.body).to include("<span class=\"target\">#{appeal.account.username}</span>")
    end
  end

  describe 'POST #approve' do
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    before do
      post :approve, params: { id: appeal.id }
    end

    it 'unsuspends a suspended account' do
      expect(target_account.reload.suspended?).to be false
    end

    it 'redirects back to the strike page' do
      expect(response).to redirect_to(disputes_strike_path(appeal.strike))
    end

    it 'notifies target account about approved appeal', :sidekiq_inline do
      expect(UserMailer.deliveries.size).to eq(1)
      expect(UserMailer.deliveries.first.to.first).to eq(target_account.user.email)
      expect(UserMailer.deliveries.first.subject).to eq(I18n.t('user_mailer.appeal_approved.subject', date: I18n.l(appeal.created_at)))
    end
  end

  describe 'POST #reject' do
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    before do
      post :reject, params: { id: appeal.id }
    end

    it 'redirects back to the strike page' do
      expect(response).to redirect_to(disputes_strike_path(appeal.strike))
    end

    it 'notifies target account about rejected appeal', :sidekiq_inline do
      expect(UserMailer.deliveries.size).to eq(1)
      expect(UserMailer.deliveries.first.to.first).to eq(target_account.user.email)
      expect(UserMailer.deliveries.first.subject).to eq(I18n.t('user_mailer.appeal_rejected.subject', date: I18n.l(appeal.created_at)))
    end
  end
end
