require 'rails_helper'

RSpec.describe Admin::GroupsController, type: :controller do
  render_views

  before { sign_in current_user, scope: :user }

  describe 'GET #index' do
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    around do |example|
      default_per_page = Group.default_per_page
      Group.paginates_per 1
      example.run
      Group.paginates_per default_per_page
    end

    it 'filters with parameters' do
      new = GroupFilter.method(:new)

      expect(GroupFilter).to receive(:new) do |params|
        h = params.to_h

        expect(h[:origin]).to eq 'local'
        expect(h[:by_domain]).to eq 'domain'
        expect(h[:status]).to eq 'active'
        expect(h[:display_name]).to eq 'display name'

        new.call({})
      end

      get :index, params: {
        origin: 'local',
        by_domain: 'domain',
        status: 'active',
        display_name: 'display name',
      }
    end

    it 'paginates groups' do
      Fabricate(:group)

      get :index, params: { page: 1 }

      groups = assigns(:groups)
      expect(groups.count).to eq 1
      expect(groups.klass).to be Group
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
    let(:group) { Fabricate(:group) }

    it 'returns http success' do
      get :show, params: { id: group.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #redownload', skip: 'TODO' do
  end

  describe 'POST #remove_avatar' do
    subject { post :remove_avatar, params: { id: group.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:group) { Fabricate(:group) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in removing avatar' do
        is_expected.to redirect_to admin_group_path(group.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to remove avatar' do
        is_expected.to have_http_status :forbidden
      end
    end
  end
end
