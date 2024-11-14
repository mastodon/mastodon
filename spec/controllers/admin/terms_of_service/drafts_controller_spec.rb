# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TermsOfService::DraftsController do
  render_views

  let(:user) { Fabricate(:admin_user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    subject { put :update, params: params }

    let!(:terms) { Fabricate :terms_of_service, published_at: nil }

    context 'with publishing params' do
      let(:params) { { terms_of_service: { text: 'new' }, action_type: 'publish' } }

      it 'publishes the record' do
        expect { subject }
          .to change(Admin::ActionLog, :count).by(1)

        expect(response)
          .to redirect_to(admin_terms_of_service_index_path)
        expect(terms.reload.published_at)
          .to_not be_nil
      end
    end

    context 'with non publishing params' do
      let(:params) { { terms_of_service: { text: 'new' }, action_type: 'save_draft' } }

      it 'updates but does not publish the record' do
        expect { subject }
          .to_not change(Admin::ActionLog, :count)

        expect(response)
          .to redirect_to(admin_terms_of_service_draft_path)
        expect(terms.reload.published_at)
          .to be_nil
      end
    end

    context 'with invalid params' do
      let(:params) { { terms_of_service: { text: '' }, action_type: 'save_draft' } }

      it 'does not update the record' do
        subject

        expect(response)
          .to have_http_status(:success)
      end
    end
  end
end
