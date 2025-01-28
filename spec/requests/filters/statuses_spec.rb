# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filters Statuses' do
  describe 'POST /filters/:filter_id/statuses/batch' do
    before { sign_in(user) }

    let(:filter) { Fabricate :custom_filter, account: user.account }
    let(:user) { Fabricate :user }

    it 'gracefully handles invalid nested params' do
      post batch_filter_statuses_path(filter.id, form_status_filter_batch_action: 'invalid')

      expect(response)
        .to redirect_to(edit_filter_path(filter))
    end
  end
end
