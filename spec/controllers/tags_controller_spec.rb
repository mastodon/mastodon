require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  render_views

  describe 'GET #show' do
    let!(:tag)     { Fabricate(:tag, name: 'test') }
    let!(:local)  { Fabricate(:status, tags: [ tag ], text: 'local #test') }
    let!(:remote) { Fabricate(:status, tags: [ tag ], text: 'remote #test', account: Fabricate(:account, domain: 'remote')) }
    let!(:late)  { Fabricate(:status, tags: [ tag ], text: 'late #test') }

    context 'when tag exists' do
      it 'returns http success' do
        get :show, params: { id: 'test', max_id: late.id }
        expect(response).to have_http_status(:success)
      end

      it 'renders public layout' do
        get :show, params: { id: 'test', max_id: late.id }
        expect(response).to render_template layout: 'public'
      end

      it 'renders only local statuses if local parameter is specified' do
        get :show, params: { id: 'test', local: true, max_id: late.id }

        expect(assigns(:tag)).to eq tag
        statuses = assigns(:statuses).to_a
        expect(statuses.size).to eq 1
        expect(statuses[0]).to eq local
      end

      it 'renders local and remote statuses if local parameter is not specified' do
        get :show, params: { id: 'test', max_id: late.id }

        expect(assigns(:tag)).to eq tag
        statuses = assigns(:statuses).to_a
        expect(statuses.size).to eq 2
        expect(statuses[0]).to eq remote
        expect(statuses[1]).to eq local
      end

      it 'filters statuses by the current account' do
        user = Fabricate(:user)
        user.account.block!(remote.account)

        sign_in(user)
        get :show, params: { id: 'test', max_id: late.id }

        expect(assigns(:tag)).to eq tag
        statuses = assigns(:statuses).to_a
        expect(statuses.size).to eq 1
        expect(statuses[0]).to eq local
      end
    end

    context 'when tag does not exist' do
      it 'returns http missing for non-existent tag' do
        get :show, params: { id: 'none' }

        expect(response).to have_http_status(:missing)
      end
    end
  end
end
