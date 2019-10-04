# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TagsController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true)
  end

  describe 'GET #index' do
    let!(:tag) { Fabricate(:tag) }

    before do
      get :index
    end

    it 'returns status 200' do
      expect(response).to have_http_status(200)
    end
  end
end
