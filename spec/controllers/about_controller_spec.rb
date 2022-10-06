require 'rails_helper'

RSpec.describe AboutController, type: :controller do
  render_views

  describe 'GET #more' do
    before do
      get :more
    end

    it 'assigns @instance_presenter' do
      expect(assigns(:instance_presenter)).to be_kind_of InstancePresenter
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end
end
