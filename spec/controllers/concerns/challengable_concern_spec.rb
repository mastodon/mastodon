# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChallengableConcern do
  render_views

  controller(ApplicationController) do
    include ChallengableConcern # rubocop:disable RSpec/DescribedClass

    before_action :require_challenge!

    def foo
      render plain: 'foo'
    end

    def bar
      render plain: 'bar'
    end

    def baz
      render plain: 'baz'
    end
  end

  before do
    routes.draw do
      get    'foo' => 'anonymous#foo'
      post   'bar' => 'anonymous#bar'
      delete 'baz' => 'anonymous#baz'
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
        expect(response.parsed_body)
          .to have_title(I18n.t('challenge.prompt'))
      end
    end

    context 'with POST requests' do
      before { post :bar }

      it 'renders challenge' do
        expect(response.parsed_body)
          .to have_title(I18n.t('challenge.prompt'))
      end

      it 'accepts correct password' do
        post :bar, params: { form_challenge: { current_password: password } }

        expect(response.body)
          .to eq 'bar'
        expect(session[:challenge_passed_at])
          .to_not be_nil
      end

      it 'rejects wrong password' do
        post :bar, params: { form_challenge: { current_password: 'dddfff888123' } }

        expect(response.parsed_body)
          .to have_title(I18n.t('challenge.prompt'))
        expect(session[:challenge_passed_at])
          .to be_nil
      end
    end

    context 'with DELETE requests' do
      before { delete :baz }

      it 'renders challenge asking to confirm with the same request method' do
        expect(response.parsed_body)
          .to have_title(I18n.t('challenge.prompt'))
          .and have_css('form input[name="_method"][value="delete"]', visible: :all)
      end

      it 'accepts correct password' do
        delete :baz, params: { form_challenge: { current_password: password } }

        expect(response.body)
          .to eq 'baz'
        expect(session[:challenge_passed_at])
          .to_not be_nil
      end
    end
  end
end
