# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::ApplicationsController do
  render_views

  let!(:user) { Fabricate(:user) }
  let!(:app) { Fabricate(:application, owner: user) }

  before do
    sign_in user, scope: :user
  end

  describe 'regenerate' do
    let(:token) { user.token_for_app(app) }

    it 'creates new token' do
      expect(token).to_not be_nil
      post :regenerate, params: { id: app.id }

      expect(user.token_for_app(app)).to_not eql(token)
    end
  end
end
