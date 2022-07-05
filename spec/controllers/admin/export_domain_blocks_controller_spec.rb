require 'rails_helper'

RSpec.describe Admin::ExportDomainBlocksController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')), scope: :user
  end

  describe 'GET #export' do
    it 'renders instances' do
      Fabricate(:domain_block, domain: 'bad.domain', severity: 'silence', public_comment: 'bad')
      Fabricate(:domain_block, domain: 'worse.domain', severity: 'suspend', reject_media: true, reject_reports: true, public_comment: 'worse', obfuscate: true)
      Fabricate(:domain_block, domain: 'reject.media', severity: 'noop', reject_media: true, public_comment: 'reject media')
      Fabricate(:domain_block, domain: 'no.op', severity: 'noop', public_comment: 'noop')

      get :export, params: { format: :csv }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(IO.read(File.join(file_fixture_path, 'domain_blocks.csv')))
    end
  end

  describe 'POST #import' do
    it 'blocks imported domains' do
      post :import, params: { admin_import: { data: fixture_file_upload('domain_blocks.csv') } }

      expect(assigns(:domain_blocks).map(&:domain)).to match_array ['bad.domain', 'worse.domain', 'reject.media']
    end
  end

  it 'displays error on no file selected' do
    post :import, params: { admin_import: {} }
    expect(flash[:alert]).to eq(I18n.t('admin.export_domain_blocks.no_file'))
  end
end
