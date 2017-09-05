require 'rails_helper'

RSpec.describe Settings::FavouriteTagsController, type: :controller do
  render_views

  before do
    @user = Fabricate(:user)
    sign_in @user, scope: :user
  end

  describe "GET #index" do
    before do
      get :index
    end

    it 'assigns @favourite_tag' do
      expect(assigns(:favourite_tag)).to be_kind_of FavouriteTag
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:tag_name) { 'dummy_tag' }
    let(:params) {
      {
        favourite_tag: {
          tag_attributes: {
            name: tag_name
          },
          visibility: 'public'
        }
      }
    }
    let!(:tag) { Fabricate(:tag, name: tag_name) }

    subject { post :create, params: params }

    it 'after create, tag' do
      expect { subject }.not_to change(Tag, :count)
      expect(response).to redirect_to(settings_favourite_tags_path)
    end

    it 'after create, favourite tag' do
      expect { subject }.to change { FavouriteTag.count }.by(1)
      expect(response).to redirect_to(settings_favourite_tags_path)
    end

    context 'when the tag has already been favourite.' do
      before do
        Fabricate(:favourite_tag, account: @user.account, tag: tag)
      end

      it 'should not create any tags and should render index template' do
        expect { subject }.not_to change(FavouriteTag, :count)
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:tag) { Fabricate(:tag, name: 'dummy_tag') }
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: @user.account, tag: tag) }
    let(:params) {
      {
        id: favourite_tag.id
      } 
    }

    subject { delete :destroy, params: params }
    
    it 'after destroy, tag' do
      expect { subject }.not_to change(Tag, :count)
      expect(response).to redirect_to(settings_favourite_tags_path)
    end

    it 'after destroy, favourite tag' do
      expect { subject }.to change { FavouriteTag.count }.by(-1)
      expect(response).to redirect_to(settings_favourite_tags_path)
    end
  end
end
