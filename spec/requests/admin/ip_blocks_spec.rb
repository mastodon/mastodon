# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin IP Blocks' do
  before { sign_in Fabricate(:admin_user) }

  describe 'POST /admin/ip_blocks' do
    it 'gracefully handles invalid nested params' do
      post admin_ip_blocks_path(ip_block: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end

  describe 'POST /admin/ip_blocks/batch' do
    it 'gracefully handles invalid nested params' do
      post batch_admin_ip_blocks_path(form_ip_block_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_ip_blocks_path)
    end
  end

  describe 'GET /admin/ip_blocks' do
    let!(:ip_block) { Fabricate(:ip_block, ip: '192.2.2.2/32') }
    let!(:range_ip_block) { Fabricate(:ip_block, ip: '192.2.2.200/32') }
    let!(:another_range_ip_block) { Fabricate(:ip_block, ip: '192.2.2.50/32') }
    let!(:other_ip_block) { Fabricate(:ip_block, ip: '192.2.2.0/24') }

    context 'when searching single ip address' do
      let(:params) { { ip: '192.2.2.1' } }

      it 'renders successfully with partial ip address' do
        get admin_ip_blocks_path(params)

        expect(response.body).to not_include(admin_accounts_path(ip: ip_block.ip))
          .and not_include(admin_accounts_path(ip: range_ip_block.ip))
          .and not_include(admin_accounts_path(ip: another_range_ip_block.ip))
        expect(response.body).to include(admin_accounts_path(ip: other_ip_block.ip))
      end
    end

    context 'when searching within a range' do
      let(:params) { { ip: '192.2.2.0/24' } }

      it 'renders ips within range' do
        get admin_ip_blocks_path(params)

        expect(response.body).to include(admin_accounts_path(ip: ip_block.ip))
          .and include(admin_accounts_path(ip: range_ip_block.ip))
          .and include(admin_accounts_path(ip: another_range_ip_block.ip))
          .and include(admin_accounts_path(ip: other_ip_block.ip))
      end
    end
  end
end
