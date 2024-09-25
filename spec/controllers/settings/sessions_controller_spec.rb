# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::SessionsController do
  render_views

  let(:user) { Fabricate(:user) }
  let(:session_activation) { Fabricate(:session_activation, user: user) }

  before { sign_in user, scope: :user }

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: id } }

    context 'when session activation exists' do
      let(:id) { session_activation.id }

      it 'destroys session activation' do
        expect(subject).to redirect_to edit_user_registration_path
        expect(SessionActivation.find_by(id: id)).to be_nil
      end
    end

    context 'when session activation does not exist' do
      let(:id) { session_activation.id + 1000 }

      it 'destroys session activation' do
        expect(subject).to have_http_status 404
      end
    end
  end
end
