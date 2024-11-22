# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SiteUploadsController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'DELETE #destroy' do
    let(:site_upload) { Fabricate(:site_upload, var: 'thumbnail') }

    it 'returns http success' do
      delete :destroy, params: { id: site_upload.id }

      expect(response).to redirect_to(admin_settings_path)
    end
  end
end
