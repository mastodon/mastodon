# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  controller do
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

    before do
      Timecop.freeze
      sign_in user, scope: :user
    end

    after do
      Timecop.return
    end

    it 'does not track when there is a recent sign in' do
      user.update(current_sign_in_at: 60.minutes.ago)
      expect { get :show }.to_not change { user.reload.current_sign_in_at }
    end

    it 'tracks when sign in is nil' do
      user.update(current_sign_in_at: nil, last_sign_in_at: nil)

      get :show
      user.reload

      expect(user.current_sign_in_at).to be_within(1.0).of(Time.now)
      expect(user.last_sign_in_at).to be_within(1.0).of(Time.now)
    end

    it 'tracks when sign in is older than one day' do
      user.update(current_sign_in_at: 2.days.ago, last_sign_in_at: 4.days.ago)

      get :show
      user.reload

      expect(user.current_sign_in_at).to be_within(1.0).of(Time.now)
      expect(user.last_sign_in_at).to be_within(1.0).of(2.days.ago)
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

        user.update(current_sign_in_at: 'Wed, 05 Jul 2017 22:10:52 UTC +00:00', last_sign_in_at: 'Tue, 04 Jul 2017 14:45:56 UTC +00:00')
      end

      it 'updates last sign in date such that a regeneration is triggered' do
        allow(RegenerationWorker).to receive(:perform_async)

        get :show
        user.reload

        expect(user.current_sign_in_at).to be_within(1.0).of(Time.now)
        expect(user.last_sign_in_at).to be < 2.weeks.ago
      end

      it 'sets a regeneration marker while regenerating' do
        allow(RegenerationWorker).to receive(:perform_async)
        get :show

        expect(Redis.current.get("account:#{user.account_id}:regeneration")).to eq 'true'
        expect(RegenerationWorker).to have_received(:perform_async)
      end

      it 'sets the regeneration marker to expire' do
        allow(RegenerationWorker).to receive(:perform_async)
        get :show

        expect(Redis.current.ttl("account:#{user.account_id}:regeneration")).to be >= 0
      end

      it 'regenerates feed when sign in is older than two weeks' do
        get :show

        expect(Redis.current.zcard(FeedManager.instance.key(:home, user.account_id))).to eq 3
        expect(Redis.current.get("account:#{user.account_id}:regeneration")).to be_nil
      end
    end
  end
end
