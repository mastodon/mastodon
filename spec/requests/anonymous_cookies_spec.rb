# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Anonymous visits' do
  around do |example|
    old = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    example.run

    ActionController::Base.allow_forgery_protection = old
  end

  describe 'account pages' do
    it 'do not set cookies' do
      alice = Fabricate(:account, username: 'alice', display_name: 'Alice')
      _status = Fabricate(:status, account: alice, text: 'Hello World')

      get '/@alice'

      expect(response.cookies).to be_empty
    end
  end

  describe 'status pages' do
    it 'do not set cookies' do
      alice = Fabricate(:account, username: 'alice', display_name: 'Alice')
      status = Fabricate(:status, account: alice, text: 'Hello World')

      get short_account_status_url(alice, status)

      expect(response.cookies).to be_empty
    end
  end

  describe 'the /about page' do
    it 'does not set cookies' do
      get '/about'

      expect(response.cookies).to be_empty
    end
  end
end
