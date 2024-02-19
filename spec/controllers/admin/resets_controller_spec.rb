# frozen_string_literal: true

require 'rails_helper'

describe Admin::ResetsController do
  render_views

  subject { post :create, params: { account_id: account.id } }

  let(:account) { Fabricate(:account) }

  before do
    sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')), scope: :user
  end

  describe 'POST #create', :sidekiq_inline do
    it 'redirects to admin accounts page' do
      emails = capture_emails { subject }

      expect(emails.size)
        .to eq(2)
      expect(emails).to have_attributes(
        first: have_attributes(
          to: include(account.user.email),
          subject: I18n.t('devise.mailer.password_change.subject')
        ),
        last: have_attributes(
          to: include(account.user.email),
          subject: I18n.t('devise.mailer.reset_password_instructions.subject')
        )
      )
      expect(response).to redirect_to(admin_account_path(account.id))
    end
  end
end
