# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Domain Blocks' do
  describe 'POST /admin/domain_blocks/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_domain_blocks_path(form_domain_block_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_instances_path(limited: '1'))
    end
  end
end
