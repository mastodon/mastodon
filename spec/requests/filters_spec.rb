# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filters' do
  describe 'GET /filters' do
    context 'with signed out user' do
      it 'redirects to sign in page' do
        get filters_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end
end
