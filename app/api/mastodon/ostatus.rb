module Mastodon
  class Ostatus < Grape::API
    format :txt

    before do
      @account = Account.find(params[:id])
    end

    resource :subscriptions do
      helpers do
        def subscription_url(account)
          "https://649841dc.ngrok.io/api#{subscriptions_path(id: account.id)}"
        end
      end

      desc 'Receive updates from a feed'

      params do
        requires :id, type: String, desc: 'Account ID'
      end

      post ':id' do
        body = request.body.read

        if @account.subscription(subscription_url(@account)).verify(body, env['HTTP_X_HUB_SIGNATURE'])
          ProcessFeedUpdateService.new.(body, @account)
          status 201
        else
          status 202
        end
      end

      desc 'Confirm PuSH subscription to a feed'

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
      desc 'Receive Salmon updates'

      params do
        requires :id, type: String, desc: 'Account ID'
      end

      post ':id' do
        # todo
      end
    end
  end
end
