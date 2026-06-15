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
    let(:ip_block) { Fabricate(:ip_block, ip: '192.2.2.2') }
    let(:other_ip_block) { Fabricate(:ip_block, ip: '192.4.4.2') }
    let(:another_ip_block) { Fabricate(:ip_block, ip: '192.5.5.2') }

    context 'with partial ip address in search field' do
      let(:params) { { ip: '192.2' } }

      before do
        ip_block
        other_ip_block
        another_ip_block
      end

      it 'renders successfully with partial ip address' do
        get admin_ip_blocks_path(params)

        expect(response).to have_http_status(200)
        expect(response.body).to include('192.2.2.2/32')
        expect(response.body).to_not include('192.4.4.2')
      end
    end

    context 'with full ip address in search field' do
      let(:params) { { ip: '192.2.2.1' } }

      before do
        ip_block
        other_ip_block
        another_ip_block
      end

      it 'renders successfully with partial ip address' do
        get admin_ip_blocks_path(params)

        expect(response).to have_http_status(200)
        expect(response.body).to_not include('192.2.2.2')
      end
    end
  end
end
