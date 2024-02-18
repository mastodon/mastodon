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

      it 'notifies staff about new appeal and redirects back to strike page', :sidekiq_inline do
        subject

        expect(ActionMailer::Base.deliveries.first.to).to eq([admin.email])
        expect(response).to redirect_to(disputes_strike_path(strike.id))
      end
    end

    context 'with invalid params' do
      let(:current_user) { Fabricate(:user) }
      let(:strike) { Fabricate(:account_warning, target_account: current_user.account) }
      let(:params) { { strike_id: strike.id, appeal: { text: '' } } }

      it 'does not send email and renders strike show page', :sidekiq_inline do
        subject

        expect(ActionMailer::Base.deliveries.size).to eq(0)
        expect(response).to render_template('disputes/strikes/show')
      end
    end
  end
end
