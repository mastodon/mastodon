require 'rails_helper'

describe Admin::RolesController do
  render_views

  let(:admin) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in admin, scope: :user
  end
end
