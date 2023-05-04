# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChallengableConcern do
  controller(ApplicationController) do
    include ChallengableConcern

    before_action :require_challenge!

    def foo
      render plain: 'foo'
    end

    def bar
      render plain: 'bar'
    end
  end

  before do
    routes.draw do
      get  'foo' => 'anonymous#foo'
      post 'bar' => 'anonymous#bar'
    end
  end

  context 'with a no-password user' do
    let(:user) { Fabricate(:user, external: true, password: nil) }

    before do
      sign_in user
    end

    context 'with GET requests' do
      before { get :foo }

      it 'does not ask for password' do
        expect(response.body).to eq 'foo'
      end
    end

    context 'with POST requests' do
      before { post :bar }

      it 'does not ask for password' do
        expect(response.body).to eq 'bar'
      end
    end
  end

  context 'with recent challenge in session' do
    let(:password) { 'foobar12345' }
    let(:user) { Fabricate(:user, password: password) }

    before do
      sign_in user
    end

    context 'with GET requests' do
      before { get :foo, session: { challenge_passed_at: Time.now.utc } }

      it 'does not ask for password' do
        expect(response.body).to eq 'foo'
      end
    end

    context 'with POST requests' do
      before { post :bar, session: { challenge_passed_at: Time.now.utc } }

      it 'does not ask for password' do
        expect(response.body).to eq 'bar'
      end
    end
  end

  context 'with a password user' do
    let(:password) { 'foobar12345' }
    let(:user) { Fabricate(:user, password: password) }

    before do
      sign_in user
    end

    context 'with GET requests' do
      before { get :foo }

      it 'renders challenge' do
        expect(response).to render_template('auth/challenges/new')
      end

      # See Auth::ChallengesControllerSpec
    end

    context 'with POST requests' do
      before { post :bar }

      it 'renders challenge' do
        expect(response).to render_template('auth/challenges/new')
      end

      it 'accepts correct password' do
        post :bar, params: { form_challenge: { current_password: password } }
        expect(response.body).to eq 'bar'
        expect(session[:challenge_passed_at]).to_not be_nil
      end

      it 'rejects wrong password' do
        post :bar, params: { form_challenge: { current_password: 'dddfff888123' } }
        expect(response.body).to render_template('auth/challenges/new')
        expect(session[:challenge_passed_at]).to be_nil
      end
    end
  end
end
