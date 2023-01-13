require 'rails_helper'

RSpec.describe Disputes::AppealsController, type: :controller do
  render_views

  before { sign_in current_user, scope: :user }

  let!(:admin) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  describe '#create' do
    let(:current_user) { Fabricate(:user) }
    let(:strike) { Fabricate(:account_warning, target_account: current_user.account) }

    before do
      allow(AdminMailer).to receive(:new_appeal).and_return(double('email', deliver_later: nil))
      post :create, params: { strike_id: strike.id, appeal: { text: 'Foo' } }
    end

    it 'notifies staff about new appeal' do
      expect(AdminMailer).to have_received(:new_appeal).with(admin.account, Appeal.last)
    end

    it 'redirects back to the strike page' do
      expect(response).to redirect_to(disputes_strike_path(strike.id))
    end
  end
end
