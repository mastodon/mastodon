require 'rails_helper'

describe Subscription::Api::InvitesController, type: :controller do
  routes { Subscription::Engine.routes }

  let(:user) { Fabricate(:user, account: Fabricate(:account)) }
  let(:app) { Fabricate(:application) }
  let(:token) { Doorkeeper::AccessToken.find_or_create_for(application: app, resource_owner: user, scopes: 'read', use_refresh_token: false) }
  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe '#index' do
    it 'returns the invite associated with the users active subscription' do
      subscription = Fabricate(:stripe_subscription, user_id: user.id, invite: Fabricate(:invite), status: 'active')

      get :index, params: { access_token: token.token }

      expect(response).to have_http_status(200)
      expect(response.body).to include(subscription.invite.code)
    end

    it 'does not return invites for inactive subscriptions' do
      subscription = Fabricate(:stripe_subscription, user_id: user.id, invite: Fabricate(:invite), status: 'canceled')

      get :index, params: { access_token: token.token }

      expect(response).to have_http_status(200)
      expect(response.body).to_not include(subscription.invite.code)
    end

    it 'returns invites for all active subscriptions' do
      subscription = Fabricate(:stripe_subscription, user_id: user.id, invite: Fabricate(:invite), status: 'active')
      subscription2 = Fabricate(:stripe_subscription, user_id: user.id, invite: Fabricate(:invite), status: 'active')
      subscription3 = Fabricate(:stripe_subscription, user_id: user.id, invite: Fabricate(:invite), status: 'canceled')

      get :index, params: { access_token: token.token }

      expect(response).to have_http_status(200)
      expect(response.body).to include(subscription.invite.code)
      expect(response.body).to include(subscription2.invite.code)
      expect(response.body).to_not include(subscription3.invite.code)
    end
  end
end
