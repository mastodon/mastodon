# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Username Blocks' do
  describe 'GET /admin/username_blocks' do
    before { sign_in Fabricate(:admin_user) }

    it 'returns http success' do
      get admin_username_blocks_path

      expect(response)
        .to have_http_status(200)
    end
  end

  describe 'POST /admin/username_blocks' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_username_blocks_path(username_block: 'invalid')

      expect(response)
        .to have_http_status(400)
    end

    it 'creates a username block' do
      post admin_username_blocks_path(username_block: { username: 'banana', comparison: 'contains', allow_with_approval: '0' })

      expect(response)
        .to redirect_to(admin_username_blocks_path)
      expect(UsernameBlock.find_by(username: 'banana'))
        .to_not be_nil
    end
  end

  describe 'POST /admin/username_blocks/batch' do
    before { sign_in Fabricate(:admin_user) }

    let(:username_blocks) { Fabricate.times(2, :username_block) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_username_blocks_path(form_username_block_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_username_blocks_path)
    end

    it 'deletes selected username blocks' do
      post batch_admin_username_blocks_path(form_username_block_batch: { username_block_ids: username_blocks.map(&:id) }, delete: '1')

      expect(response)
        .to redirect_to(admin_username_blocks_path)
      expect(UsernameBlock.where(id: username_blocks.map(&:id)))
        .to be_empty
    end
  end

  describe 'GET /admin/username_blocks/new' do
    before { sign_in Fabricate(:admin_user) }

    it 'returns http success' do
      get new_admin_username_block_path

      expect(response)
        .to have_http_status(200)
    end
  end

  describe 'GET /admin/username_blocks/:id/edit' do
    before { sign_in Fabricate(:admin_user) }

    let(:username_block) { Fabricate(:username_block) }

    it 'returns http success' do
      get edit_admin_username_block_path(username_block)

      expect(response)
        .to have_http_status(200)
    end
  end

  describe 'PUT /admin/username_blocks/:id' do
    before { sign_in Fabricate(:admin_user) }

    let(:username_block) { Fabricate(:username_block, username: 'banana') }

    it 'updates username block' do
      put admin_username_block_path(username_block, username_block: { username: 'bebebe' })

      expect(response)
        .to redirect_to(admin_username_blocks_path)
      expect(username_block.reload.username)
        .to eq 'bebebe'
    end
  end
end
