require 'rails_helper'

describe AccountUnfollowController do
  render_views

  let(:user) { Fabricate(:user) }
  let(:alice) { Fabricate(:account, username: 'alice') }

  describe 'POST #create' do
    let(:service) { double }

    subject { post :create, params: { account_username: alice.username } }

    before do
      allow(UnfollowService).to receive(:new).and_return(service)
      allow(service).to receive(:call)
    end

    context 'when account is permanently suspended' do
      before do
        alice.suspend!
        alice.deletion_request.destroy
        subject
      end

      it 'returns http gone' do
        expect(response).to have_http_status(410)
      end
    end

    context 'when account is temporarily suspended' do
      before do
        alice.suspend!
        subject
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when signed out' do
      before do
        subject
      end

      it 'does not unfollow' do
        expect(UnfollowService).not_to receive(:new)
      end
    end

    context 'when signed in' do
      before do
        sign_in(user)
        subject
      end

      it 'redirects to account path' do
        expect(service).to have_received(:call).with(user.account, alice)
        expect(response).to redirect_to(account_path(alice))
      end
    end
  end
end
