# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::ListsController do
  render_views

  describe 'GET #index' do
    it 'returns a csv of the domains' do
      account = Fabricate(:account)
      user = Fabricate(:user, account: account)
      list = Fabricate(:list, account: account, title: 'The List')
      Fabricate(:list_account, list: list, account: account)

      sign_in user, scope: :user
      get :index, format: :csv

      expect(response.body).to match 'The List'
    end
  end
end
