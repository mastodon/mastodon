module Mastodon
  class Ostatus < Grape::API
    format :txt

    before do
      @account = Account.find(params[:id])
    end

    resource :subscriptions do
      helpers do
        include ApplicationHelper
      end

      desc 'Receive updates from an account'

      params do
        requires :id, type: String, desc: 'Account ID'
      end

      post ':id' do
        body = request.body.read

        if @account.subscription(subscription_url(@account)).verify(body, env['HTTP_X_HUB_SIGNATURE'])
          ProcessFeedService.new.(body, @account)
          status 201
        else
          status 202
        end
      end

      desc 'Confirm PuSH subscription to an account'

      params do
        requires :id, type: String, desc: 'Account ID'
        requires 'hub.topic', type: String, desc: 'Topic URL'
        requires 'hub.verify_token', type: String, desc: 'Verification token'
        requires 'hub.challenge', type: String, desc: 'Hub challenge'
      end

      get ':id' do
        if @account.subscription(subscription_url(@account)).valid?(params['hub.topic'], params['hub.verify_token'])
          params['hub.challenge']
        else
          error! :not_found, 404
        end
      end
    end

    resource :salmon do
      desc 'Receive Salmon updates targeted to account'

      params do
        requires :id, type: String, desc: 'Account ID'
      end

      post ':id' do
        ProcessInteractionService.new.(request.body.read, @account)
        status 201
      end
    end
  end
end
