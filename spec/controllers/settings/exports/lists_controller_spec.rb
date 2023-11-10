# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::ListsController do
  render_views

  describe 'GET #index' do
    let(:account) { Fabricate(:account) }
    let(:user) { Fabricate(:user, account: account) }
    let(:list) { Fabricate(:list, account: account, title: 'The List') }

    before do
      Fabricate(:list_account, list: list, account: account)
      sign_in user, scope: :user
    end

    it 'returns a csv of the domains' do
      get :index, format: :csv

      expect(response.body)
        .to match 'The List'
    end
  end
end
