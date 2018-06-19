# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Admin::SubscriptionsController, type: :controller do
  render_views

  describe 'GET #index' do
    around do |example|
      default_per_page = Subscription.default_per_page
      Subscription.paginates_per 1
      example.run
      Subscription.paginates_per default_per_page
    end

    before do
      sign_in Fabricate(:user, admin: true), scope: :user
    end

    it 'renders subscriptions' do
      Fabricate(:subscription)
      specified = Fabricate(:subscription)

      get :index

      subscriptions = assigns(:subscriptions)
      expect(subscriptions.count).to eq 1
      expect(subscriptions[0]).to eq specified

      expect(response).to have_http_status(200)
    end
  end
end
