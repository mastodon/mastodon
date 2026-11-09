# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Instances' do
  describe 'GET /admin/instances/:id' do
    before { sign_in Fabricate(:admin_user) }

    context 'with an unknown domain' do
      it 'returns http success' do
        get admin_instance_path(id: 'unknown.example')

        expect(response)
          .to have_http_status(200)
      end
    end

    context 'with an invalid domain' do
      it 'returns http success' do
        get admin_instance_path(id: ' ')

        expect(response)
          .to have_http_status(200)
      end
    end
  end

  describe 'POST /admin/instances/:id/restart_delivery' do
    let(:domain) { 'example.com' }
    let(:tracker) { DeliveryFailureTracker.new(domain) }

    before do
      Fabricate(:account, domain: domain)
      Instance.refresh
      tracker.track_failure!
      sign_in Fabricate(:admin_user)
    end

    context 'with an available instance' do
      it 'redirects without clearing delivery failures' do
        expect { post restart_delivery_admin_instance_path(domain) }
          .to not_change(tracker, :days)

        expect(response)
          .to redirect_to(admin_instance_path(domain))
      end
    end
  end

  describe 'DELETE /admin/instances/:id' do
    let(:domain) { 'example.com' }

    before do
      Fabricate(:account, domain: domain)
      Instance.refresh
      sign_in Fabricate(:user)
    end

    context 'when user is not admin' do
      it 'returns http forbidden without queuing a purge' do
        expect { delete admin_instance_path(domain) }
          .to not_change(Admin::DomainPurgeWorker.jobs, :size)

        expect(response)
          .to have_http_status(403)
      end
    end
  end
end
