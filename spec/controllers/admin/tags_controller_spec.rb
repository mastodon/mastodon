# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TagsController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true)
  end

  describe 'GET #index' do
    before do
      account_tag_stat = Fabricate(:tag).account_tag_stat
      account_tag_stat.update(hidden: hidden, accounts_count: 1)
      get :index, params: { hidden: hidden }
    end

    context 'with hidden tags' do
      let(:hidden) { true }

      it 'returns status 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'without hidden tags' do
      let(:hidden) { false }

      it 'returns status 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST #hide' do
    let(:tag) { Fabricate(:tag) }

    before do
      tag.account_tag_stat.update(hidden: false)
      post :hide, params: { id: tag.id }
    end

    it 'hides tag' do
      tag.reload
      expect(tag).to be_hidden
    end

    it 'redirects to admin_tags_path' do
      expect(response).to redirect_to(admin_tags_path(controller.instance_variable_get(:@filter_params)))
    end
  end

  describe 'POST #unhide' do
    let(:tag) { Fabricate(:tag) }

    before do
      tag.account_tag_stat.update(hidden: true)
      post :unhide, params: { id: tag.id }
    end

    it 'unhides tag' do
      tag.reload
      expect(tag).not_to be_hidden
    end

    it 'redirects to admin_tags_path' do
      expect(response).to redirect_to(admin_tags_path(controller.instance_variable_get(:@filter_params)))
    end
  end
end
