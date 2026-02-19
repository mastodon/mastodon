# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::AccountSerializer do
  subject do
    serialized_record_json(account, described_class, options: {
      scope: current_user,
      scope_name: :current_user,
    })
  end

  let(:default_datetime) { DateTime.new(2024, 11, 28, 16, 20, 0) }
  let(:role)    { Fabricate(:user_role, name: 'Role', highlighted: true) }
  let(:user)    { Fabricate(:user, role: role) }
  let(:account) { user.account }
  let(:current_user) { Fabricate(:user) }

  context 'when the account is suspended' do
    before do
      account.suspend!
    end

    it 'returns empty roles' do
      expect(subject['roles']).to eq []
    end
  end

  context 'when the account has a highlighted role' do
    let(:role) { Fabricate(:user_role, name: 'Role', highlighted: true) }

    it 'returns the expected role' do
      expect(subject['roles'].first).to include({ 'name' => 'Role' })
    end
  end

  context 'when the account has a non-highlighted role' do
    let(:role) { Fabricate(:user_role, name: 'Role', highlighted: false) }

    it 'returns empty roles' do
      expect(subject['roles']).to eq []
    end
  end

  context 'when the account is memorialized' do
    before do
      account.memorialize!
    end

    it 'marks it as such' do
      expect(subject['memorial']).to be true
    end
  end

  context 'when created_at is populated' do
    before do
      account.account_stat.update!(created_at: default_datetime)
    end

    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'created_at' => match_api_datetime_format
        )
    end
  end

  context 'when last_status_at is populated' do
    before do
      account.account_stat.update!(last_status_at: default_datetime)
    end

    it 'is serialized as yyyy-mm-dd' do
      expect(subject['last_status_at']).to eq('2024-11-28')
    end
  end

  describe '#feature_approval' do
    # TODO: Remove when feature flag is removed
    context 'when collections feature is disabled' do
      it 'does not include the approval policy' do
        expect(subject).to_not have_key('feature_approval')
      end
    end

    context 'when collections feature is enabled', feature: :collections do
      context 'when account is local' do
        context 'when account is discoverable' do
          it 'includes a policy that allows featuring' do
            expect(subject['feature_approval']).to include({
              'automatic' => ['public'],
              'manual' => [],
              'current_user' => 'automatic',
            })
          end
        end

        context 'when account is not discoverable' do
          let(:account) { Fabricate(:account, discoverable: false) }

          it 'includes a policy that disallows featuring' do
            expect(subject['feature_approval']).to include({
              'automatic' => [],
              'manual' => [],
              'current_user' => 'denied',
            })
          end
        end
      end

      context 'when account is remote' do
        let(:account) { Fabricate(:account, domain: 'example.com', feature_approval_policy: 0b11000000000000000010) }

        it 'includes the matching policy' do
          expect(subject['feature_approval']).to include({
            'automatic' => ['followers', 'following'],
            'manual' => ['public'],
            'current_user' => 'manual',
          })
        end
      end
    end
  end
end
