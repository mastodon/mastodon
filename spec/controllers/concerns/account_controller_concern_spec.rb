# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountControllerConcern do
  controller(ApplicationController) do
    include AccountControllerConcern

    def success
      @account = Account.last
      render plain: @account.username # rubocop:disable RSpec/InstanceVariable
    end
  end

  before do
    routes.draw { get 'success' => 'anonymous#success' }
  end

  let(:account) { Fabricate :account, username: 'username' }

  it 'sets link headers' do
    get 'success', params: { account_username: account.username }

    expect(response)
      .to have_http_status(200)
      .and have_http_link_header('http://test.host/.well-known/webfinger?resource=acct%3Ausername%40cb6e6126.ngrok.io').for(rel: 'lrdd', type: 'application/jrd+json')
      .and have_http_link_header('https://cb6e6126.ngrok.io/users/username').for(rel: 'alternate', type: 'application/activity+json')
  end
end
