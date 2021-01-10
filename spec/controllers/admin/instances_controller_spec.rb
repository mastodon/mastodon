require 'rails_helper'

RSpec.describe Admin::InstancesController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #index' do
    around do |example|
      default_per_page = Instance.default_per_page
      Instance.paginates_per 1
      example.run
      Instance.paginates_per default_per_page
    end

    it 'renders instances' do
      Fabricate(:account, domain: 'popular')
      Fabricate(:account, domain: 'popular')
      Fabricate(:account, domain: 'less.popular')

      get :index, params: { page: 2 }

      instances = assigns(:instances).to_a
      expect(instances.size).to eq 1
      expect(instances[0].domain).to eq 'less.popular'

      expect(response).to have_http_status(200)
    end
  end
end
