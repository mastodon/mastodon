# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebAppControllerConcern do
  render_views

  controller(ApplicationController) do
    include WebAppControllerConcern # rubocop:disable RSpec/DescribedClass

    def show
      render plain: 'show'
    end
  end

  before do
    routes.draw { get 'show' => 'anonymous#show' }
  end

  describe 'when signed in' do
    let(:user) { Fabricate(:user) }

    before { sign_in(user) }

    context 'when user does not require TOS interstitial' do
      before { user.update(require_tos_interstitial: false) }

      it 'renders requested page as expected' do
        get :show

        expect(response)
          .to have_http_status(:success)
        expect(response.body)
          .to match(/show/)
      end
    end

    context 'when user does require TOS interstitial' do
      before { user.update(require_tos_interstitial: true) }

      context 'when there is no TOS record' do
        before { TermsOfService.destroy_all }

        it 'renders requested page as expected' do
          get :show

          expect(response)
            .to have_http_status(:success)
          expect(response.body)
            .to match(/show/)
        end
      end

      context 'when there is a TOS record' do
        before { Fabricate :terms_of_service, published_at: 1.day.ago }

        it 'renders interstitial page instead of expected content' do
          get :show

          expect(response)
            .to have_http_status(:success)
          expect(response.body)
            .to match(I18n.t('terms_of_service_interstitial.title', domain: local_domain_uri.host))
        end
      end
    end
  end
end
