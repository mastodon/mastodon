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

  describe 'POST #approve' do
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    before do
      allow(UserMailer).to receive(:appeal_approved)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: nil))
      post :approve, params: { id: appeal.id }
    end

    it 'unsuspends a suspended account' do
      expect(target_account.reload.suspended?).to be false
    end

    it 'redirects back to the strike page' do
      expect(response).to redirect_to(disputes_strike_path(appeal.strike))
    end

    it 'notifies target account about approved appeal' do
      expect(UserMailer).to have_received(:appeal_approved).with(target_account.user, appeal)
    end
  end

  describe 'POST #reject' do
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    before do
      allow(UserMailer).to receive(:appeal_rejected)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: nil))
      post :reject, params: { id: appeal.id }
    end

    it 'redirects back to the strike page' do
      expect(response).to redirect_to(disputes_strike_path(appeal.strike))
    end

    it 'notifies target account about rejected appeal' do
      expect(UserMailer).to have_received(:appeal_rejected).with(target_account.user, appeal)
    end
  end
end
