# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TermsOfService::GeneratesController do
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

  describe 'POST #create' do
    subject { post :create, params: params }

    context 'with valid params' do
      let(:params) do
        {
          terms_of_service_generator: {
            admin_email: 'test@host.example',
            arbitration_address: '123 Main Street',
            arbitration_website: 'https://host.example',
            dmca_address: '123 DMCA Ave',
            dmca_email: 'dmca@host.example',
            domain: 'host.example',
            jurisdiction: 'Europe',
          },
        }
      end

      it 'saves new record' do
        expect { subject }
          .to change(TermsOfService, :count).by(1)
        expect(response)
          .to redirect_to(admin_terms_of_service_draft_path)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          terms_of_service_generator: {
            admin_email: 'what the',
          },
        }
      end

      it 'does not save new record' do
        expect { subject }
          .to_not change(TermsOfService, :count)
        expect(response)
          .to have_http_status(200)
      end
    end
  end
end
