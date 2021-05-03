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

  describe 'GET #edit' do
    let(:tag) { Fabricate(:tag, name: 'dummy_tag') }
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: @user.account, tag: tag) }

    context 'when the favourite tag is found.' do
      before do
        get :edit, params: { id: favourite_tag.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @favourite_tag' do
        expect(assigns(:favourite_tag)).to be_kind_of FavouriteTag
        expect(assigns(:favourite_tag)).to eq(favourite_tag)
      end
    end

    context 'when the favourite tag is not found.' do
      before do
        get :edit, params: { id: 0 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:missing)
      end
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
          visibility: 'public',
          order: 1
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

  describe 'PUT #update' do
    let(:tag) { Fabricate(:tag, name: 'dummy_tag') }
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: @user.account, tag: tag) }

    context 'The favourite tag can update.' do
      let(:params) {
        {
          id: favourite_tag.id,
          favourite_tag: {
            tag_attributes: {
              name: 'dummy_tag_' + favourite_tag.id.to_s
            },
            visibility: 'unlisted',
            order: 2
          }
        }
      }

      subject { put :update, params: params }

      it 'after update, tag' do
        expect { subject }.to change { Tag.count }.by(1)
        expect(assigns(:favourite_tag).tag.name).not_to eq('dummy_tag')
        expect(response).to redirect_to(settings_favourite_tags_path)
      end

      it 'after update, favourite tag' do
        expect { subject }.not_to change(FavouriteTag, :count)
        expect(assigns(:favourite_tag).visibility).to eq('unlisted')
        expect(assigns(:favourite_tag).order).to eq(2)
        expect(response).to redirect_to(settings_favourite_tags_path)
      end
    end

    context 'The favourite tag could not update, because tag has already been registered.' do
      let(:tag_name) { 'dummy_tag2' }
      let(:params) {
        {
          id: favourite_tag.id,
          favourite_tag: {
            tag_attributes: {
              name: tag_name
            },
            visibility: 'unlisted',
            order: 2
          }
        }
      }
      let(:tag2) { Fabricate(:tag, name: tag_name) }

      subject { put :update, params: params }

      before do
        Fabricate(:favourite_tag, account: @user.account, tag: tag2)
      end

      it 'should not update any tags and should render edit template' do
        expect { subject }.not_to change(Tag, :count)
        expect(response).to render_template(:edit)
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
