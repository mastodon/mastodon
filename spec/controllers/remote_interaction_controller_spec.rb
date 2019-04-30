# frozen_string_literal: true

require 'rails_helper'

describe RemoteInteractionController, type: :controller do
  render_views

  let(:status) { Fabricate(:status) }

  describe 'GET #new' do
    it 'returns 200' do
      get :new, params: { id: status.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    context '@remote_follow is valid' do
      it 'returns 302' do
        allow_any_instance_of(RemoteFollow).to receive(:valid?) { true }
        allow_any_instance_of(RemoteFollow).to receive(:addressable_template) do
          Addressable::Template.new('https://hoge.com')
        end

        post :create, params: { id: status.id, remote_follow: { acct: '@hoge' } }
        expect(response).to have_http_status(302)
      end
    end

    context '@remote_follow is invalid' do
      it 'returns 200' do
        allow_any_instance_of(RemoteFollow).to receive(:valid?) { false }
        post :create, params: { id: status.id, remote_follow: { acct: '@hoge' } }

        expect(response).to have_http_status(200)
      end
    end
  end
end
