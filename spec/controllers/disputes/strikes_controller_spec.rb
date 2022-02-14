require 'rails_helper'

RSpec.describe Disputes::StrikesController, type: :controller do
  render_views

  before { sign_in current_user, scope: :user }

  describe '#show' do
    let(:current_user) { Fabricate(:user) }
    let(:strike) { Fabricate(:account_warning, target_account: current_user.account) }

    before do
      get :show, params: { id: strike.id }
    end

    context 'when meant for the user' do
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when meant for a different user' do
      let(:strike) { Fabricate(:account_warning) }

      it 'returns http forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
