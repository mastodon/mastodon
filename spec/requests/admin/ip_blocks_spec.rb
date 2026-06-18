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

  describe 'get /admin/ip_blocks/' do
    let(:ip_block) { Fabricate(:ip_block, ip: '192.2.2.2/32') }
    let(:range_ip_block) { Fabricate(:ip_block, ip: '192.2.2.200/32') }
    let(:anoth_range_ip_block) { Fabricate(:ip_block, ip: '192.2.2.50/32') }
    let(:other_ip_block) { Fabricate(:ip_block, ip: '192.2.2.0/24') }

    before do
      ip_block
      range_ip_block
      anoth_range_ip_block
      other_ip_block
    end

    context 'when searching single ip address' do
      let(:params) { { ip: '192.2.2.1' } }

      it 'renders successfully with partial ip address' do
        get admin_ip_blocks_path(params)

        expect(response.body).to_not include(admin_accounts_path(ip: '192.2.2.2/32'))
        expect(response.body).to_not include(admin_accounts_path(ip: '192.2.2.200/32'))
        expect(response.body).to_not include(admin_accounts_path(ip: '192.2.2.50/32'))
        expect(response.body).to include(admin_accounts_path(ip: '192.2.2.0/24'))
      end
    end

    context 'when searching within a range' do
      let(:params) { { ip: '192.2.2.0/24' } }

      it 'renders ips within range' do
        get admin_ip_blocks_path(params)

        expect(response.body).to include(admin_accounts_path(ip: '192.2.2.2/32'))
          .and include(admin_accounts_path(ip: '192.2.2.50/32'))
          .and include(admin_accounts_path(ip: '192.2.2.0/24'))
          .and include(admin_accounts_path(ip: '192.2.2.200/32'))
      end
    end
  end
end
