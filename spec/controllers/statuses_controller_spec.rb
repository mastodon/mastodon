require 'rails_helper'

RSpec.describe StatusesController, type: :controller do
  let(:user) { Fabricate(:user) }

  before do
    sign_in :user, user
  end

  describe 'POST #create' do
    before do
      stub_request(:post, "https://pubsubhubbub.superfeedr.com/").to_return(:status => 200, :body => "", :headers => {})
      post :create, status: { text: 'Hello world' }
    end

    it 'redirects back to homepage' do
      expect(response).to redirect_to(root_path)
    end

    it 'creates a new status' do
      expect(user.account.statuses.count).to eq 1
    end
  end
end
