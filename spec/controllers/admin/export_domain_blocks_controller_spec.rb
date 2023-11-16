# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExportDomainBlocksController do
  render_views

  before do
    sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')), scope: :user
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new

      expect(response)
        .to have_http_status(200)
        .and render_template(:new)
    end
  end

  describe 'GET #export' do
    it 'renders instances' do
      Fabricate(:domain_block, domain: 'bad.domain', severity: 'silence', public_comment: 'bad server')
      Fabricate(:domain_block, domain: 'worse.domain', severity: 'suspend', reject_media: true, reject_reports: true, public_comment: 'worse server', obfuscate: true)
      Fabricate(:domain_block, domain: 'reject.media', severity: 'noop', reject_media: true, public_comment: 'reject media and test unicode characters ♥')
      Fabricate(:domain_block, domain: 'no.op', severity: 'noop', public_comment: 'noop')

      get :export, params: { format: :csv }

      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          body: eq(File.read(File.join(file_fixture_path, 'domain_blocks.csv')))
        )
    end
  end

  describe 'POST #import' do
    context 'with complete domain blocks CSV' do
      before do
        post :import, params: { admin_import: { data: fixture_file_upload('domain_blocks.csv') } }
      end

      it 'renders page with expected domain blocks' do
        expect(assigns_domain_blocks_domain_and_severity)
          .to contain_exactly(
            ['bad.domain', :silence],
            ['worse.domain', :suspend],
            ['reject.media', :noop]
          )

        expect(response)
          .to have_http_status(200)
      end
    end

    context 'with a list of only domains' do
      before do
        post :import, params: { admin_import: { data: fixture_file_upload('domain_blocks_list.txt') } }
      end

      it 'renders page with expected domain blocks' do
        expect(assigns_domain_blocks_domain_and_severity)
          .to contain_exactly(
            ['bad.domain', :suspend],
            ['worse.domain', :suspend],
            ['reject.media', :suspend]
          )

        expect(response).to have_http_status(200)
      end
    end

    private

    def assigns_domain_blocks_domain_and_severity
      assigns(:domain_blocks).map { |block| [block.domain, block.severity.to_sym] }
    end
  end

  it 'displays error on no file selected' do
    post :import, params: { admin_import: {} }

    expect(flash.to_h.symbolize_keys)
      .to include(
        alert: eq(I18n.t('admin.export_domain_blocks.no_file'))
      )
  end
end
