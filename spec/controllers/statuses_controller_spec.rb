# frozen_string_literal: true

require 'rails_helper'

describe StatusesController do
  render_views

  describe '#show' do
    context 'account is suspended' do
      it 'returns gone' do
        account = Fabricate(:account, suspended: true)
        status = Fabricate(:status, account: account)

        get :show, params: { account_username: account.username, id: status.id }

        expect(response).to have_http_status(410)
      end
    end

    context 'status is not permitted' do
      it 'raises ActiveRecord::RecordNotFound' do
        user = Fabricate(:user)
        status = Fabricate(:status)
        status.account.block!(user.account)

        sign_in(user)
        get :show, params: { account_username: status.account.username, id: status.id }

        expect(response).to have_http_status(404)
      end
    end

    context 'status is a reblog' do
      it 'redirects to the original status' do
        original_account = Fabricate(:account, domain: 'example.com')
        original_status = Fabricate(:status, account: original_account, uri: 'tag:example.com,2017:foo', url: 'https://example.com/123')
        status = Fabricate(:status, reblog: original_status)

        get :show, params: { account_username: status.account.username, id: status.id }

        expect(response).to redirect_to(original_status.url)
      end
    end

    context 'account is not suspended and status is permitted' do
      it 'assigns @account' do
        status = Fabricate(:status)
        get :show, params: { account_username: status.account.username, id: status.id }
        expect(assigns(:account)).to eq status.account
      end

      it 'assigns @status' do
        status = Fabricate(:status)
        get :show, params: { account_username: status.account.username, id: status.id }
        expect(assigns(:status)).to eq status
      end

      it 'assigns @stream_entry' do
        status = Fabricate(:status)
        get :show, params: { account_username: status.account.username, id: status.id }
        expect(assigns(:stream_entry)).to eq status.stream_entry
      end

      it 'assigns @type' do
        status = Fabricate(:status)
        get :show, params: { account_username: status.account.username, id: status.id }
        expect(assigns(:type)).to eq 'status'
      end

      it 'assigns @ancestors for ancestors of the status if it is a reply' do
        ancestor = Fabricate(:status)
        status = Fabricate(:status, in_reply_to_id: ancestor.id)

        get :show, params: { account_username: status.account.username, id: status.id }

        expect(assigns(:ancestors)).to eq [ancestor]
      end

      it 'assigns @ancestors for [] if it is not a reply' do
        status = Fabricate(:status)
        get :show, params: { account_username: status.account.username, id: status.id }
        expect(assigns(:ancestors)).to eq []
      end

      it 'assigns @descendant_threads for a thread with several statuses' do
        status = Fabricate(:status)
        child = Fabricate(:status, in_reply_to_id: status.id)
        grandchild = Fabricate(:status, in_reply_to_id: child.id)

        get :show, params: { account_username: status.account.username, id: status.id }

        expect(assigns(:descendant_threads)[0][:statuses].pluck(:id)).to eq [child.id, grandchild.id]
      end

      it 'assigns @descendant_threads for several threads sharing the same descendant' do
        status = Fabricate(:status)
        child = Fabricate(:status, in_reply_to_id: status.id)
        grandchildren = 2.times.map { Fabricate(:status, in_reply_to_id: child.id) }

        get :show, params: { account_username: status.account.username, id: status.id }

        expect(assigns(:descendant_threads)[0][:statuses].pluck(:id)).to eq [child.id, grandchildren[0].id]
        expect(assigns(:descendant_threads)[1][:statuses].pluck(:id)).to eq [grandchildren[1].id]
      end

      it 'assigns @max_descendant_thread_id for the last thread if it is hitting the status limit' do
        stub_const 'StatusesController::DESCENDANTS_LIMIT', 1
        status = Fabricate(:status)
        child = Fabricate(:status, in_reply_to_id: status.id)

        get :show, params: { account_username: status.account.username, id: status.id }

        expect(assigns(:descendant_threads)).to eq []
        expect(assigns(:max_descendant_thread_id)).to eq child.id
      end

      it 'assigns @descendant_threads for threads with :next_status key if they are hitting the depth limit' do
        stub_const 'StatusesController::DESCENDANTS_DEPTH_LIMIT', 2
        status = Fabricate(:status)
        child0 = Fabricate(:status, in_reply_to_id: status.id)
        child1 = Fabricate(:status, in_reply_to_id: child0.id)
        child2 = Fabricate(:status, in_reply_to_id: child0.id)

        get :show, params: { account_username: status.account.username, id: status.id }

        expect(assigns(:descendant_threads)[0][:statuses].pluck(:id)).not_to include child1.id
        expect(assigns(:descendant_threads)[1][:statuses].pluck(:id)).not_to include child2.id
        expect(assigns(:descendant_threads)[0][:next_status].id).to eq child1.id
        expect(assigns(:descendant_threads)[1][:next_status].id).to eq child2.id
      end

      it 'returns a success' do
        status = Fabricate(:status)
        get :show, params: { account_username: status.account.username, id: status.id }
        expect(response).to have_http_status(200)
      end

      it 'renders stream_entries/show' do
        status = Fabricate(:status)
        get :show, params: { account_username: status.account.username, id: status.id }
        expect(response).to render_template 'stream_entries/show'
      end
    end
  end
end
