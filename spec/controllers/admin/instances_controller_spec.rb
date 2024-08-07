# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::InstancesController do
  render_views

  let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  let!(:account_popular_main) { Fabricate(:account, domain: 'popular') }

  before do
    _account_less_popular = Fabricate(:account, domain: 'less.popular')
    _account_popular_other = Fabricate(:account, domain: 'popular')
    Instance.refresh

    sign_in current_user, scope: :user
  end

  describe 'GET #index' do
    around do |example|
      default_per_page = Instance.default_per_page
      Instance.paginates_per 1
      example.run
      Instance.paginates_per default_per_page
    end

    it 'renders instances' do
      get :index, params: { page: 2 }

      instances = assigns(:instances).to_a
      expect(instances.size).to eq 1
      expect(instances[0].domain).to eq 'less.popular'

      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    before do
      allow(Admin::ActionLogFilter).to receive(:new).and_call_original
    end

    it 'shows an instance page' do
      get :show, params: { id: account_popular_main.domain }

      expect(response).to have_http_status(200)

      instance = assigns(:instance)
      expect(instance).to_not be_new_record

      expect(Admin::ActionLogFilter).to have_received(:new).with(target_domain: account_popular_main.domain)

      action_logs = assigns(:action_logs).to_a
      expect(action_logs.size).to eq 0
    end

    context 'with an unknown domain' do
      it 'returns http success' do
        get :show, params: { id: 'unknown.example' }
        expect(response).to have_http_status(200)

        instance = assigns(:instance)
        expect(instance).to be_new_record
      end
    end
  end

  describe 'POST #clear_delivery_errors' do
    let(:tracker) { instance_double(DeliveryFailureTracker, clear_failures!: true) }

    before { allow(DeliveryFailureTracker).to receive(:new).and_return(tracker) }

    it 'clears instance delivery errors' do
      post :clear_delivery_errors, params: { id: account_popular_main.domain }

      expect(response).to redirect_to(admin_instance_path(account_popular_main.domain))
      expect(tracker).to have_received(:clear_failures!)
    end
  end

  describe 'POST #restart_delivery' do
    let(:tracker) { instance_double(DeliveryFailureTracker, track_success!: true) }

    before { allow(DeliveryFailureTracker).to receive(:new).and_return(tracker) }

    context 'with an unavailable instance' do
      before { Fabricate(:unavailable_domain, domain: account_popular_main.domain) }

      it 'tracks success on the instance' do
        post :restart_delivery, params: { id: account_popular_main.domain }

        expect(response).to redirect_to(admin_instance_path(account_popular_main.domain))
        expect(tracker).to have_received(:track_success!)
      end
    end

    context 'with an available instance' do
      it 'does not track success on the instance' do
        post :restart_delivery, params: { id: account_popular_main.domain }

        expect(response).to redirect_to(admin_instance_path(account_popular_main.domain))
        expect(tracker).to_not have_received(:track_success!)
      end
    end
  end

  describe 'POST #stop_delivery' do
    it 'clears instance delivery errors' do
      expect do
        post :stop_delivery, params: { id: account_popular_main.domain }
      end.to change(UnavailableDomain, :count).by(1)

      expect(response).to redirect_to(admin_instance_path(account_popular_main.domain))
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: Instance.first.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in purging instance' do
        expect(subject).to redirect_to admin_instances_path
      end
    end

    context 'when user is not admin' do
      let(:role) { nil }

      it 'fails to purge instance' do
        expect(subject).to have_http_status 403
      end
    end
  end
end
