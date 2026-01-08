# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Interaction policies' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'write:statuses' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:status) { Fabricate(:status, account: user.account) }
  let(:params) { { quote_approval_policy: 'followers' } }

  describe 'PUT /api/v1/statuses/:status_id/interaction_policy' do
    subject do
      put "/api/v1/statuses/#{status.id}/interaction_policy", headers: headers, params: params
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:statuses'

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        expect { subject }
          .to_not(change { status.reload.quote_approval_policy })

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with a status from a different user' do
      let(:status) { Fabricate(:status) }

      it 'returns http unauthorized' do
        expect { subject }
          .to_not(change { status.reload.quote_approval_policy })

        expect(response).to have_http_status(403)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when changing the interaction policy' do
      it 'changes the interaction policy, returns the updated status, and schedules distribution jobs' do
        expect { subject }
          .to change { status.reload.quote_approval_policy }.to(InteractionPolicy::POLICY_FLAGS[:followers] << 16)

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to include(
          'quote_approval' => match(
            'automatic' => ['followers'],
            'manual' => [],
            'current_user' => 'automatic'
          )
        )

        expect(DistributionWorker)
          .to have_enqueued_sidekiq_job(status.id, { 'update' => true, 'skip_notifications' => true })
        expect(ActivityPub::StatusUpdateDistributionWorker)
          .to have_enqueued_sidekiq_job(status.id, { 'updated_at' => anything })
      end
    end

    context 'when not changing the interaction policy' do
      let(:params) { { quote_approval_policy: 'nobody' } }

      it 'keeps the interaction policy, returns the status, and does not schedule distribution jobs' do
        expect { subject }
          .to_not(change { status.reload.quote_approval_policy }.from(0))

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to include(
          'quote_approval' => match(
            'automatic' => [],
            'manual' => [],
            'current_user' => 'automatic'
          )
        )

        expect(DistributionWorker)
          .to_not have_enqueued_sidekiq_job
        expect(ActivityPub::StatusUpdateDistributionWorker)
          .to_not have_enqueued_sidekiq_job
      end
    end

    context 'when trying to change the interaction policy of a private post' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :private) }
      let(:params) { { quote_approval_policy: 'public' } }

      it 'keeps the interaction policy, returns the status, and does not schedule distribution jobs' do
        expect { subject }
          .to_not(change { status.reload.quote_approval_policy }.from(0))

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to include(
          'quote_approval' => match(
            'automatic' => [],
            'manual' => [],
            'current_user' => 'automatic'
          )
        )

        expect(DistributionWorker)
          .to_not have_enqueued_sidekiq_job
        expect(ActivityPub::StatusUpdateDistributionWorker)
          .to_not have_enqueued_sidekiq_job
      end
    end
  end
end
