# frozen_string_literal: true

require 'rails_helper'

describe Admin::AnnouncementsController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success and renders new' do
      get :new

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let(:announcement) { Fabricate(:announcement) }

    it 'returns http success and renders edit' do
      get :edit, params: { id: announcement.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    it 'creates a new announcement and redirects' do
      expect do
        post :create, params: { announcement: { text: 'The announcement message.' } }
      end.to change(Announcement, :count).by(1)

      expect(response).to redirect_to(admin_announcements_path)
      expect(flash.notice).to match(I18n.t('admin.announcements.published_msg'))
    end
  end

  describe 'PUT #update' do
    let(:announcement) { Fabricate(:announcement, text: 'Original text') }

    it 'updates an announcement and redirects' do
      put :update, params: { id: announcement.id, announcement: { text: 'Updated text.' } }

      expect(response).to redirect_to(admin_announcements_path)
      expect(flash.notice).to match(I18n.t('admin.announcements.updated_msg'))
    end
  end

  describe 'DELETE #destroy' do
    let!(:announcement) { Fabricate(:announcement, text: 'Original text') }

    it 'destroys an announcement and redirects' do
      expect do
        delete :destroy, params: { id: announcement.id }
      end.to change(Announcement, :count).by(-1)

      expect(response).to redirect_to(admin_announcements_path)
      expect(flash.notice).to match(I18n.t('admin.announcements.destroyed_msg'))
    end
  end

  describe 'POST #publish' do
    subject { post :publish, params: { id: announcement.id } }

    let(:announcement) { Fabricate(:announcement, published_at: nil) }

    it 'marks announcement published' do
      subject

      expect(announcement.reload).to be_published
      expect(response).to redirect_to admin_announcements_path
    end
  end

  describe 'POST #unpublish' do
    subject { post :unpublish, params: { id: announcement.id } }

    let(:announcement) { Fabricate(:announcement, published_at: 4.days.ago) }

    it 'marks announcement as not published' do
      subject

      expect(announcement.reload).to_not be_published
      expect(response).to redirect_to admin_announcements_path
    end
  end
end
