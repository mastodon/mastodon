# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Ignored Server Checks' do
  before do
    Admin::ServerCheck.destroy_all
  end

  context 'when signed in as lower permissions user' do
    let(:check) { Fabricate('Admin::ServerCheck', key: 'rules') }
    let(:user_role) { Fabricate(:user_role, permissions: UserRole::Flags::NONE) }

    before { sign_in Fabricate(:user, role: user_role) }

    describe 'POST /admin/ignored_server_checks/:key' do
      it 'returns http forbidden' do
        post admin_ignored_server_check_path(key: check.key)

        expect(response).to have_http_status(403)
      end
    end

    describe 'DELETE /admin/ignored_server_checks/:key' do
      it 'returns http forbidden' do
        delete admin_ignored_server_check_path(key: check.key)

        expect(response).to have_http_status(403)
      end
    end
  end

  context 'when signed in as an admin' do
    let(:role) do
      Fabricate(:user_role, permissions_as_keys: [:administrator])
    end
    let(:user) { Fabricate(:user, role:) }

    before { sign_in user }

    describe 'POST /admin/ignored_server_checks/:key' do
      let(:check) { Fabricate('Admin::ServerCheck', key: 'rules', ignored: false) }

      it 'marks a check as ignored' do
        expect { post admin_ignored_server_check_path(key: check.key) }
          .to(change { check.reload.ignored? })
      end
    end

    describe 'DELETE /admin/ignored_server_checks/:key' do
      let(:check) { Fabricate('Admin::ServerCheck', key: 'rules', ignored: true) }

      it 'marks a check as not ignored' do
        expect { delete admin_ignored_server_check_path(key: check.key) }
          .to(change { check.reload.ignored? })
      end
    end
  end
end
