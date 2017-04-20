require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views
  let(:user) { Fabricate(:user) }
  let(:alice) { Fabricate(:account, id: 1, username: 'alica') }

  describe 'GET #index' do
    it 'redirects to about page' do
      get :index
      expect(response).to redirect_to(about_path)
    end

    context 'GET /web/accounts/:id' do
      before { controller.request.env['ORIGINAL_FULLPATH'] = "/web/accounts/#{alice.id}" }
      it 'redirects to @username page' do
        get :index
        expect(response).to redirect_to(short_account_path(alice))
      end
    end
  end
end
