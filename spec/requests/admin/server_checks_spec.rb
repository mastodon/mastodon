# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Server Checks' do
  context 'when signed in as lower permissions user' do
    let(:user_role) { Fabricate(:user_role, permissions: UserRole::Flags::NONE) }

    before { sign_in Fabricate(:user, role: user_role) }

    describe 'GET /admin/server_checks' do
      it 'returns http forbidden' do
        get admin_server_checks_path

        expect(response).to have_http_status(403)
      end
    end
  end

  context 'when signed in as an admin' do
    let(:user) { Fabricate(:admin_user) }

    before { sign_in(user) }

    describe 'GET /admin/server_checks' do
      it 'returns the index page' do
        get admin_server_checks_path

        expect(response).to have_http_status(200)
      end
    end
  end
end
