# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  describe 'authorize' do
    controller do
      include Authorization

      def index
        authorize Status.find(params.require(:id)), params[:query]
      end

      def show
        authorize Status.find(params.require(:id)), params[:query]
      end
    end

    context 'if not authorized' do
      it 'raises Mastodon::NotFound if the action is show and the query is nil' do
        status = Fabricate(:status, visibility: :direct)
        post :show, params: { id: status }
        expect(response).to have_http_status 404
      end

      it 'raise Mastodon::NotFound if the query is show?' do
        status = Fabricate(:status, visibility: :direct)
        post :index, params: { id: status, query: :show? }
        expect(response).to have_http_status 404
      end

      it 'raise Mastodon::NotFound if the record is not for show?' do
        status = Fabricate(:status, visibility: :direct)
        post :show, params: { id: status, query: :reblog? }
        expect(response).to have_http_status 404
      end

      it 'raise Mastodon::NotPermittedError if the record is for show?' do
        user = Fabricate(:user)
        status = Fabricate(:status, account: user.account, visibility: :direct)
        sign_in user

        post :show, params: { id: status, query: :reblog? }

        expect(response).to have_http_status 403
      end
    end
  end
end
