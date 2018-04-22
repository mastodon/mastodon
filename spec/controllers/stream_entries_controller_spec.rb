require 'rails_helper'

RSpec.describe StreamEntriesController, type: :controller do
  render_views

  shared_examples 'before_action' do |route|
    context 'when account is not suspended anbd stream_entry is available' do
      it 'assigns instance variables' do
        status = Fabricate(:status)

        get route, params: { account_username: status.account.username, id: status.stream_entry.id }

        expect(assigns(:account)).to eq status.account
        expect(assigns(:stream_entry)).to eq status.stream_entry
        expect(assigns(:type)).to eq 'status'
      end

      it 'sets Link headers' do
        alice = Fabricate(:account, username: 'alice')
        status = Fabricate(:status, account: alice)

        get route, params: { account_username: alice.username, id: status.stream_entry.id }

        expect(response.headers['Link'].to_s).to eq "<http://test.host/users/alice/updates/#{status.stream_entry.id}.atom>; rel=\"alternate\"; type=\"application/atom+xml\", <https://cb6e6126.ngrok.io/users/alice/statuses/#{status.id}>; rel=\"alternate\"; type=\"application/activity+json\""
      end
    end

    context 'when account is suspended' do
      it 'returns http status 410' do
        account = Fabricate(:account, suspended: true)
        status = Fabricate(:status, account: account)

        get route, params: { account_username: account.username, id: status.stream_entry.id }

        expect(response).to have_http_status(410)
      end
    end

    context 'when activity is nil' do
      it 'raises ActiveRecord::RecordNotFound' do
        account = Fabricate(:account)
        stream_entry = Fabricate.build(:stream_entry, account: account, activity: nil, activity_type: 'Status')
        stream_entry.save!(validate: false)

        get route, params: { account_username: account.username, id: stream_entry.id }

        expect(response).to have_http_status(404)
      end
    end

    context 'when it is hidden and it is not permitted' do
      it 'raises ActiveRecord::RecordNotFound' do
        status = Fabricate(:status)
        user = Fabricate(:user)
        status.account.block!(user.account)
        status.stream_entry.update!(hidden: true)

        sign_in(user)
        get route, params: { account_username: status.account.username, id: status.stream_entry.id }

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'GET #show' do
    include_examples 'before_action', :show

    it 'redirects to status page' do
      status = Fabricate(:status)

      get :show, params: { account_username: status.account.username, id: status.stream_entry.id }

      expect(response).to redirect_to(short_account_status_url(status.account, status))
    end

    it 'returns http success with Atom' do
      status = Fabricate(:status)
      get :show, params: { account_username: status.account.username, id: status.stream_entry.id }, format: 'atom'
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #embed' do
    include_examples 'before_action', :embed

    it 'redirects to new embed page' do
      status = Fabricate(:status)

      get :embed, params: { account_username: status.account.username, id: status.stream_entry.id }

      expect(response).to redirect_to(embed_short_account_status_url(status.account, status))
    end
  end
end
