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

    it 'regenerates feed when sign in is older than two weeks' do
      Sidekiq::Testing.fake! do
        user.update(current_sign_in_at: 3.weeks.ago)
        sign_in user, scope: :user
        get :show

        expect_updated_sign_in_at(user)
        expect(RegenerationWorker).to have_enqueued_sidekiq_job user.account_id
      end
    end

    def expect_updated_sign_in_at(user)
      expect(user.reload.current_sign_in_at).to be_within(1.0).of(Time.now.utc)
    end
  end
end
