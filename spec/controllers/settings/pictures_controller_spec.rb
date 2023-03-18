# frozen_string_literal: true

require 'rails_helper'

describe Settings::PicturesController do
  render_views

  let!(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'DELETE #destroy' do
    context 'with invalid picture id' do
      it 'returns http bad request' do
        delete :destroy, params: { id: 'invalid' }
        expect(response).to have_http_status(400)
      end
    end
  end
end
