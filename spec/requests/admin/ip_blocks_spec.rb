# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin IP Blocks' do
  describe 'POST /admin/ip_blocks' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_ip_blocks_path(ip_block: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end

  describe 'POST /admin/ip_blocks/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_ip_blocks_path(form_ip_block_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_ip_blocks_path)
    end
  end
end
