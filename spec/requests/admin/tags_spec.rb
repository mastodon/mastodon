# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Tags' do
  describe 'PUT /admin/tags/:id' do
    before { sign_in Fabricate(:admin_user) }

    let(:tag) { Fabricate :tag }

    it 'gracefully handles invalid nested params' do
      put admin_tag_path(tag.id, tag: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
