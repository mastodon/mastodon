require 'rails_helper'

describe AccountUnfollowController do
  render_views

  let(:user) { Fabricate(:user) }
  let(:alice) { Fabricate(:account, username: 'alice') }

  describe 'POST #create' do
    before do
      sign_in(user)
    end

    it 'redirects to account path' do
      service = double
      allow(UnfollowService).to receive(:new).and_return(service)
      allow(service).to receive(:call)

      post :create, params: { account_username: alice.username }

      expect(service).to have_received(:call).with(user.account, alice)
      expect(response).to redirect_to(account_path(alice))
    end
  end
end
