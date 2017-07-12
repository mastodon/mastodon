require 'rails_helper'

describe ManifestsController do
  render_views

  describe 'GET #show' do
    before do
      get :show, format: :json
    end

    it 'assigns @instance_presenter' do
      expect(assigns(:instance_presenter)).to be_kind_of InstancePresenter
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
