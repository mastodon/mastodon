# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ConfirmationsController do
  render_views

  before do
    sign_in Fabricate(:admin_user), scope: :user
  end

  describe 'POST #create' do
    it 'confirms the user' do
      user = Fabricate(:user, confirmed_at: nil)
      post :create, params: { account_id: user.account.id }

      expect(response).to redirect_to(admin_accounts_path)
      expect(user.reload).to be_confirmed
    end

    it 'raises an error when there is no account' do
      post :create, params: { account_id: 'fake' }

      expect(response).to have_http_status(404)
    end

    it 'raises an error when there is no user' do
      account = Fabricate(:account, user: nil)
      post :create, params: { account_id: account.id }

      expect(response).to have_http_status(404)
    end
  end

  describe 'POST #resend' do
    subject { post :resend, params: { account_id: user.account.id } }

    let!(:user) { Fabricate(:user, confirmed_at: confirmed_at) }

    before do
      allow(UserMailer).to receive(:confirmation_instructions) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }
    end

    context 'when email is not confirmed' do
      let(:confirmed_at) { nil }

      it 'resends confirmation mail' do
        expect(subject).to redirect_to admin_accounts_path
        expect(flash[:notice]).to eq I18n.t('admin.accounts.resend_confirmation.success')
        expect(UserMailer).to have_received(:confirmation_instructions).once
      end
    end

    context 'when email is confirmed' do
      let(:confirmed_at) { Time.zone.now }

      it 'does not resend confirmation mail' do
        expect(subject).to redirect_to admin_accounts_path
        expect(flash[:error]).to eq I18n.t('admin.accounts.resend_confirmation.already_confirmed')
        expect(UserMailer).to_not have_received(:confirmation_instructions)
      end
    end
  end
end
