require 'rails_helper'

RSpec.describe Admin::BlacklistedEmailDomainsController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #index' do
    around do |example|
      default_per_page = BlacklistedEmailDomain.default_per_page
      BlacklistedEmailDomain.paginates_per 1
      example.run
      BlacklistedEmailDomain.paginates_per default_per_page
    end

    it 'renders email blacks' do
      2.times { Fabricate(:blacklisted_email_domain) }

      get :index, params: { page: 2 }

      assigned = assigns(:blacklisted_email_domains)
      expect(assigned.count).to eq 1
      expect(assigned.klass).to be BlacklistedEmailDomain
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'assigns a new email black' do
      get :new

      expect(assigns(:blacklisted_email_domain)).to be_instance_of(BlacklistedEmailDomain)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'blocks the domain when succeeded to save' do
      post :create, params: { blacklisted_email_domain: { domain: 'example.com', note: 'memo' } }

      expect(flash[:notice]).to eq I18n.t('admin.blacklisted_email_domains.created_msg')
      expect(response).to redirect_to(admin_blacklisted_email_domains_path)
    end
  end

  describe 'DELETE #destroy' do
    it 'unblocks the domain' do
      blacklisted_email_domain = Fabricate(:blacklisted_email_domain)
      delete :destroy, params: { id: blacklisted_email_domain.id } 

      expect(flash[:notice]).to eq I18n.t('admin.blacklisted_email_domains.destroyed_msg')
      expect(response).to redirect_to(admin_blacklisted_email_domains_path)
    end
  end
end
