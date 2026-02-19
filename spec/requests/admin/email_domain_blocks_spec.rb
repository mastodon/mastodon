# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Email Domain Blocks' do
  describe 'POST /admin/email_domain_blocks' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_email_domain_blocks_path(email_domain_block: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end

  describe 'POST /admin/email_domain_blocks/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_email_domain_blocks_path(form_email_domain_block_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_email_domain_blocks_path)
    end
  end
end
