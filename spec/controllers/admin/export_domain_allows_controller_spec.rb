# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExportDomainAllowsController do
  render_views

  before do
    sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')), scope: :user
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new

      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #export' do
    it 'renders instances' do
      Fabricate(:domain_allow, domain: 'good.domain')
      Fabricate(:domain_allow, domain: 'better.domain')

      get :export, params: { format: :csv }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(domain_allows_csv_file)
    end
  end

  describe 'POST #import' do
    it 'allows imported domains' do
      post :import, params: { admin_import: { data: fixture_file_upload('domain_allows.csv') } }

      expect(response).to redirect_to(admin_instances_path)

      # Header should not be imported
      expect(DomainAllow.where(domain: '#domain').present?).to be(false)

      # Domains should now be added
      get :export, params: { format: :csv }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(domain_allows_csv_file)
    end

    it 'displays error on no file selected' do
      post :import, params: { admin_import: {} }
      expect(response).to redirect_to(admin_instances_path)
      expect(flash[:error]).to eq(I18n.t('admin.export_domain_allows.no_file'))
    end
  end

  private

  def domain_allows_csv_file
    File.read(File.join(file_fixture_path, 'domain_allows.csv'))
  end
end
