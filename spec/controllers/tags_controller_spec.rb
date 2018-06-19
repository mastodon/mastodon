require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  render_views

  describe 'GET #show' do
    let!(:tag)     { Fabricate(:tag, name: 'test') }
    let!(:local)   { Fabricate(:status, tags: [tag], text: 'local #test') }
    let!(:remote)  { Fabricate(:status, tags: [tag], text: 'remote #test', account: Fabricate(:account, domain: 'remote')) }
    let!(:late)    { Fabricate(:status, tags: [tag], text: 'late #test') }

    context 'when tag exists' do
      it 'returns http success' do
        get :show, params: { id: 'test', max_id: late.id }
        expect(response).to have_http_status(200)
      end

      it 'renders application layout' do
        get :show, params: { id: 'test', max_id: late.id }
        expect(response).to render_template layout: 'application'
      end
    end

    context 'when tag does not exist' do
      it 'returns http missing for non-existent tag' do
        get :show, params: { id: 'none' }

        expect(response).to have_http_status(404)
      end
    end
  end
end
