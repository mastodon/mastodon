require 'rails_helper'

RSpec.describe Admin::ChangeEmailsController, type: :controller do
  render_views

  let(:admin) { Fabricate(:user, admin: true) }

  before do
    sign_in admin
  end

  describe "GET #show" do
    it "returns http success" do
      account = Fabricate(:account)
      user = Fabricate(:user, account: account)

      get :show, params: { account_id: account.id }

      expect(response).to have_http_status(200)
    end
  end

  describe "GET #update" do
    before do
      allow(UserMailer).to receive(:confirmation_instructions).and_return(double('email', deliver_later: nil))
    end

    it "returns http success" do
      account = Fabricate(:account)
      user = Fabricate(:user, account: account)

      previous_email = user.email

      post :update, params: { account_id: account.id, user: { unconfirmed_email: 'test@example.com' } }

      user.reload

      expect(user.email).to eq previous_email
      expect(user.unconfirmed_email).to eq 'test@example.com'
      expect(user.confirmation_token).not_to be_nil

      expect(UserMailer).to have_received(:confirmation_instructions).with(user, user.confirmation_token, { to: 'test@example.com' })

      expect(response).to redirect_to(admin_account_path(account.id))
    end
  end
end
