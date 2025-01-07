# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Migrations' do
  describe 'GET #show' do
    context 'when user is not signed in' do
      subject { get '/settings/migration' }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  describe 'POST #create' do
    context 'when user is not signed in' do
      subject { post '/settings/migration' }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end
end
