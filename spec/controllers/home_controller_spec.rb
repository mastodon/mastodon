require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  describe 'GET #index' do
    subject { get :index }

    context 'when not signed in' do
      context 'when requested path is tag timeline' do
        before { @request.path = '/web/timelines/tag/name' }
        it { is_expected.to redirect_to '/tags/name' }
      end

      it 'redirects to about page' do
        @request.path = '/'
        is_expected.to redirect_to(about_path)
      end
    end

    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before { sign_in(user) }

      it 'assigns @body_classes' do
        subject
        expect(assigns(:body_classes)).to eq 'app-body'
      end

      it 'assigns @initial_state_json' do
        subject
        initial_state_json = json_str_to_hash(assigns(:initial_state_json))
        expect(initial_state_json[:meta]).to_not be_nil
        expect(initial_state_json[:compose]).to_not be_nil
        expect(initial_state_json[:accounts]).to_not be_nil
        expect(initial_state_json[:settings]).to_not be_nil
        expect(initial_state_json[:media_attachments]).to_not be_nil
      end
    end
  end
end
