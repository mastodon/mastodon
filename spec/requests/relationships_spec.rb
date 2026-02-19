# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Relationships' do
  describe 'PUT /relationships' do
    before { sign_in Fabricate(:user) }

    it 'gracefully handles invalid nested params' do
      put relationships_path(form_account_batch: 'invalid')

      expect(response)
        .to redirect_to(relationships_path)
    end
  end
end
