# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Invites' do
  let(:user) { Fabricate(:user) }

  before { sign_in user }

  context 'when not everyone can invite' do
    before { UserRole.everyone.update(permissions: UserRole.everyone.permissions & ~UserRole::FLAGS[:invite_users]) }

    describe 'GET /invites' do
      it 'returns http forbidden' do
        get invites_path

        expect(response)
          .to have_http_status(403)
      end
    end

    describe 'POST /invites' do
      it 'returns http forbidden' do
        post invites_path, params: { invite: { max_users: '10', expires_in: 1800 } }

        expect(response)
          .to have_http_status(403)
      end
    end
  end
end
