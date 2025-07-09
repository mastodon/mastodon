# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Disputes Strikes' do
  before { sign_in current_user }

  describe 'GET /disputes/strikes/:id' do
    let(:current_user) { Fabricate(:user) }

    context 'when meant for a different user' do
      let(:strike) { Fabricate(:account_warning) }

      it 'returns http forbidden' do
        get disputes_strike_path(strike)

        expect(response)
          .to have_http_status(403)
      end
    end
  end
end
