require 'rails_helper'

RSpec.describe AboutController, type: :controller do
  render_views

  describe 'GET #show' do
    before do
      get :show
    end

    it 'assigns @body_classes' do
      expect(assigns(:body_classes)).to eq 'about-body'
    end

    it 'assigns @instance_presenter' do
      expect(assigns(:instance_presenter)).to be_kind_of InstancePresenter
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #more' do
    before do
      get :more
    end

    it 'assigns @body_classes' do
      expect(assigns(:body_classes)).to eq 'about-body'
    end

    it 'assigns @instance_presenter' do
      expect(assigns(:instance_presenter)).to be_kind_of InstancePresenter
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #terms' do
    before do
      get :terms
    end

    it 'assigns @body_classes' do
      expect(assigns(:body_classes)).to eq 'about-body'
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'helper_method :new_user' do
    it 'returns a new User' do
      user = @controller.view_context.new_user
      expect(user).to be_kind_of User
      expect(user.account).to be_kind_of Account
    end
  end
end
