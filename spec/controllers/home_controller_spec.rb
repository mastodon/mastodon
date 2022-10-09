require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  describe 'GET #index' do
    subject { get :index }

    context 'when not signed in' do
      context 'when requested path is tag timeline' do
        it 'returns http success' do
          @request.path = '/web/timelines/tag/name'
          is_expected.to have_http_status(:success)
        end
      end

      it 'redirects to about page' do
        @request.path = '/'
        is_expected.to redirect_to(about_path)
      end
    end

    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before do
        sign_in(user)
      end

      it 'returns http success' do
        is_expected.to have_http_status(:success)
      end
    end
  end
end
