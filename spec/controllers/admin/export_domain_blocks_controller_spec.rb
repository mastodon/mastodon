# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExportDomainBlocksController do
  render_views

  before do
    sign_in Fabricate(:admin_user), scope: :user
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new

      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #export' do
    it 'renders instances' do
      Fabricate(:domain_block, domain: 'bad.domain', severity: 'silence', public_comment: 'bad server')
      Fabricate(:domain_block, domain: 'worse.domain', severity: 'suspend', reject_media: true, reject_reports: true, public_comment: 'worse server', obfuscate: true)
      Fabricate(:domain_block, domain: 'reject.media', severity: 'noop', reject_media: true, public_comment: 'reject media and test unicode characters ♥')
      Fabricate(:domain_block, domain: 'no.op', severity: 'noop', public_comment: 'noop')

      get :export, params: { format: :csv }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(domain_blocks_csv_file)
    end

    private

    def domain_blocks_csv_file
      File.read(File.join(file_fixture_path, 'domain_blocks.csv'))
    end
  end

  describe 'POST #import' do
    context 'with complete domain blocks CSV' do
      before do
        post :import, params: { admin_import: { data: fixture_file_upload('domain_blocks.csv') } }
      end

      it 'renders page with expected domain blocks and returns http success' do
        expect(mapped_batch_table_rows).to contain_exactly(['bad.domain', :silence], ['worse.domain', :suspend], ['reject.media', :noop])
        expect(response).to have_http_status(200)
      end
    end

    context 'with a list of only domains' do
      before do
        post :import, params: { admin_import: { data: fixture_file_upload('domain_blocks_list.txt') } }
      end

      it 'renders page with expected domain blocks and returns http success' do
        expect(mapped_batch_table_rows).to contain_exactly(['bad.domain', :suspend], ['worse.domain', :suspend], ['reject.media', :suspend])
        expect(response).to have_http_status(200)
      end
    end

    def mapped_batch_table_rows
      batch_table_rows.map { |row| [row.at_css('[id$=_domain]')['value'], row.at_css('[id$=_severity]')['value'].to_sym] }
    end

    def batch_table_rows
      response.parsed_body.css('body div.batch-table__row')
    end
  end

  it 'displays error on no file selected' do
    post :import, params: { admin_import: {} }
    expect(flash[:alert]).to eq(I18n.t('admin.export_domain_blocks.no_file'))
  end
end
