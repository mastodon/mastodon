# frozen_string_literal: true

require 'rails_helper'

describe UserTrackingConcern do
  controller(ApplicationController) do
    include UserTrackingConcern

    def show
      render plain: 'show'
    end
  end

  before do
    routes.draw { get 'show' => 'anonymous#show' }
  end

  describe 'when signed in' do
    let(:user) { Fabricate(:user) }

    it 'does not track when there is a recent sign in' do
      user.update(current_sign_in_at: 60.minutes.ago)
      prior = user.current_sign_in_at
      sign_in user, scope: :user
      get :show

      expect(user.reload.current_sign_in_at).to be_within(1.0).of(prior)
    end

    it 'tracks when sign in is nil' do
      user.update(current_sign_in_at: nil)
      sign_in user, scope: :user
      get :show

      expect_updated_sign_in_at(user)
    end

    it 'tracks when sign in is older than one day' do
      user.update(current_sign_in_at: 2.days.ago)
      sign_in user, scope: :user
      get :show

      expect_updated_sign_in_at(user)
    end

    describe 'feed regeneration' do
      before do
        alice = Fabricate(:account)
        bob   = Fabricate(:account)

        user.account.follow!(alice)
        user.account.follow!(bob)

        Fabricate(:status, account: alice, text: 'hello world')
        Fabricate(:status, account: bob, text: 'yes hello')
        Fabricate(:status, account: user.account, text: 'test')

        user.update(last_sign_in_at: 'Tue, 04 Jul 2017 14:45:56 UTC +00:00', current_sign_in_at: 'Wed, 05 Jul 2017 22:10:52 UTC +00:00')

        sign_in user, scope: :user
      end

      it 'sets a regeneration marker while regenerating' do
        allow(RegenerationWorker).to receive(:perform_async)
        get :show

        expect_updated_sign_in_at(user)
        expect(redis.get("account:#{user.account_id}:regeneration")).to eq 'true'
        expect(RegenerationWorker).to have_received(:perform_async)
      end

      it 'sets the regeneration marker to expire' do
        allow(RegenerationWorker).to receive(:perform_async)
        get :show
        expect(redis.ttl("account:#{user.account_id}:regeneration")).to be >= 0
      end

      it 'regenerates feed when sign in is older than two weeks', :inline_jobs do
        get :show

        expect_updated_sign_in_at(user)
        expect(redis.zcard(FeedManager.instance.key(:home, user.account_id))).to eq 3
        expect(redis.get("account:#{user.account_id}:regeneration")).to be_nil
      end
    end

    def expect_updated_sign_in_at(user)
      expect(user.reload.current_sign_in_at).to be_within(1.0).of(Time.now.utc)
    end
  end
end
