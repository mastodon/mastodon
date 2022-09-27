require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  render_views

  let(:group) { Fabricate(:group) }

  shared_examples 'cacheable response' do
    it 'does not set cookies' do
      expect(response.cookies).to be_empty
      expect(response.headers['Set-Cookies']).to be nil
    end

    it 'does not set sessions' do
      expect(session).to be_empty
    end

    it 'returns public Cache-Control header' do
      expect(response.headers['Cache-Control']).to include 'public'
    end
  end

  describe 'GET #show' do
    let(:format) { 'html' }

    let(:group_membership)     { Fabricate(:group_membership, group: group) }
    let(:unrelated_group)      { Fabricate(:group) }
    let(:unrelated_membership) { Fabricate(:group_membership, group: unrelated_group) }
    let!(:status)              { Fabricate(:status, group: group, visibility: 'group', account: group_membership.account) }
    let!(:unapproved_status)   { Fabricate(:status, group: group, visibility: 'group', account: group_membership.account, approval_status: :pending) }
    let!(:unrelated_status)    { Fabricate(:status, group: unrelated_group, visibility: 'group', account: unrelated_membership.account) }

    context 'as HTML' do
      let(:format) { 'html' }

      context 'when the group is temporarily suspended' do
        before do
          group.suspend!
        end

        it 'returns http forbidden' do
          get :show, params: { id: group.id, format: format }
          expect(response).to have_http_status(403)
        end
      end

      context do
        before do
          get :show, params: { id: group.id, format: format }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'renders show template' do
          expect(response).to render_template(:show)
        end
      end
    end

    context 'as JSON' do
      let(:authorized_fetch_mode) { false }
      let(:format) { 'json' }

      before do
        allow(controller).to receive(:authorized_fetch_mode?).and_return(authorized_fetch_mode)
      end

      context 'when the group is suspended temporarily' do
        before do
          group.suspend!
        end

        it 'returns http success' do
          get :show, params: { id: group.id, format: format }
          expect(response).to have_http_status(200)
        end
      end

      context do
        before do
          get :show, params: { id: group.id, format: format }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it_behaves_like 'cacheable response'

        it 'renders group' do
          json = body_as_json
          expect(json).to include(:id, :type, :inbox, :publicKey, :name, :summary)
        end

        context 'in authorized fetch mode' do
          let(:authorized_fetch_mode) { true }

          it 'returns http unauthorized' do
            expect(response).to have_http_status(401)
          end
        end
      end

      context 'when signed in' do
        let(:user) { Fabricate(:user) }

        before do
          sign_in(user)
          get :show, params: { id: group.id, format: format }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it 'returns public Cache-Control header' do
          expect(response.headers['Cache-Control']).to include 'public'
        end

        it 'renders group' do
          json = body_as_json
          expect(json).to include(:id, :type, :inbox, :publicKey, :name, :summary)
        end
      end

      context 'with signature' do
        let(:remote_account) { Fabricate(:account, domain: 'example.com') }

        before do
          allow(controller).to receive(:signed_request_actor).and_return(remote_account)
          get :show, params: { id: group.id, format: format }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it_behaves_like 'cacheable response'

        it 'renders group' do
          json = body_as_json
          expect(json).to include(:id, :type, :inbox, :publicKey, :name, :summary)
        end

        context 'in authorized fetch mode' do
          let(:authorized_fetch_mode) { true }

          it 'returns http success' do
            expect(response).to have_http_status(200)
          end

          it 'returns application/activity+json' do
            expect(response.media_type).to eq 'application/activity+json'
          end

          it 'returns private Cache-Control header' do
            expect(response.headers['Cache-Control']).to include 'private'
          end

          it 'returns Vary header with Signature' do
            expect(response.headers['Vary']).to include 'Signature'
          end

          it 'renders group' do
            json = body_as_json
            expect(json).to include(:id, :type, :inbox, :publicKey, :name, :summary)
          end
        end
      end
    end
  end
end
