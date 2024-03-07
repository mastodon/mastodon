# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::EmergencyRulesController do
  before do
    Fabricate('Emergency::Trigger')
    Fabricate('Emergency::SettingOverrideAction')
    Fabricate('Emergency::RateLimitAction')
  end

  describe 'the index route' do
    context 'when not logged in' do
      it 'returns HTTP forbidden' do
        get '/admin/emergency_rules'

        expect(response).to have_http_status(403)
      end
    end

    context 'when logged in as a regular user' do
      before do
        sign_in Fabricate(:user), scope: :user
      end

      it 'returns HTTP forbidden' do
        get '/admin/emergency_rules'

        expect(response).to have_http_status(403)
      end
    end

    context 'when logged in as a moderator' do
      let(:user)  { Fabricate(:user, role: UserRole.find_by!(name: 'Moderator')) }

      before do
        sign_in user, scope: :user
      end

      it 'returns HTTP success' do
        get '/admin/emergency_rules'

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'the deactivation route' do
    let(:rule) { Fabricate('Emergency::Rule') }

    before do
      rule.trigger!(1.day.ago)
    end

    context 'when not logged in' do
      it 'returns HTTP forbidden' do
        post "/admin/emergency_rules/#{rule.id}/deactivate"

        expect(response).to have_http_status(403)
      end
    end

    context 'when logged in as a regular user' do
      before do
        sign_in Fabricate(:user), scope: :user
      end

      it 'returns HTTP forbidden' do
        post "/admin/emergency_rules/#{rule.id}/deactivate"

        expect(response).to have_http_status(403)
      end
    end

    context 'when logged in as a moderator' do
      let(:user)  { Fabricate(:user, role: UserRole.find_by!(name: 'Moderator')) }

      before do
        sign_in user, scope: :user
      end

      it 'redirects' do
        post "/admin/emergency_rules/#{rule.id}/deactivate"

        expect(response).to redirect_to '/admin/emergency_rules'
      end

      it 'deactivates the rule' do
        expect { post "/admin/emergency_rules/#{rule.id}/deactivate" }.to change { rule.reload.active? }.from(true).to(false)
      end
    end
  end
end
