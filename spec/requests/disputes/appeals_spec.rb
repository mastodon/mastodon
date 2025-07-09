# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Disputes Appeals' do
  describe 'POST /disputes/appeals' do
    before { sign_in strike.target_account.user }

    let(:strike) { Fabricate :account_warning }

    it 'gracefully handles invalid nested params' do
      post disputes_strike_appeal_path(strike, appeal: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
