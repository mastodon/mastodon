# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Disputes::AppealsController do
  render_views

  before { sign_in current_user, scope: :user }

  let!(:admin) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  describe '#create' do
    subject { post :create, params: params }

    context 'with valid params' do
      let(:current_user) { Fabricate(:user) }
      let(:strike) { Fabricate(:account_warning, target_account: current_user.account) }
      let(:params) { { strike_id: strike.id, appeal: { text: 'Foo' } } }

      it 'notifies staff about new appeal and redirects back to strike page', :inline_jobs do
        emails = capture_emails { subject }

        expect(emails.size)
          .to eq(1)
        expect(emails.first)
          .to have_attributes(
            to: contain_exactly(admin.email),
            subject: eq(I18n.t('admin_mailer.new_appeal.subject', username: current_user.account.acct, instance: Rails.configuration.x.local_domain))
          )
        expect(response).to redirect_to(disputes_strike_path(strike.id))
      end
    end

    context 'with invalid params' do
      let(:current_user) { Fabricate(:user) }
      let(:strike) { Fabricate(:account_warning, target_account: current_user.account) }
      let(:params) { { strike_id: strike.id, appeal: { text: '' } } }

      it 'does not send email and renders strike show page', :inline_jobs do
        emails = capture_emails { subject }

        expect(emails).to be_empty
        expect(response).to render_template('disputes/strikes/show')
      end
    end
  end
end
