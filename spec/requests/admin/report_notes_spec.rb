# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Report Notes' do
  describe 'POST /admin/report_notes' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_report_notes_path(report_note: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
