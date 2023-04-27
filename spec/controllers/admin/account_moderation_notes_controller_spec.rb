# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AccountModerationNotesController, type: :controller do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
  let(:target_account) { Fabricate(:account) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #create' do
    subject { post :create, params: params }

    context 'when parameters are valid' do
      let(:params) { { account_moderation_note: { target_account_id: target_account.id, content: 'test content' } } }

      it 'successfully creates a note' do
        expect { subject }.to change { AccountModerationNote.count }.by(1)
        expect(subject).to redirect_to admin_account_path(target_account.id)
      end
    end

    context 'when parameters are invalid' do
      let(:params) { { account_moderation_note: { target_account_id: target_account.id, content: '' } } }

      it 'falls to create a note' do
        expect { subject }.to_not change { AccountModerationNote.count }
        expect(subject).to render_template 'admin/accounts/show'
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: note.id } }

    let!(:note) { Fabricate(:account_moderation_note, account: account, target_account: target_account) }
    let(:account) { Fabricate(:account) }

    it 'destroys note' do
      expect { subject }.to change { AccountModerationNote.count }.by(-1)
      expect(subject).to redirect_to admin_account_path(target_account.id)
    end
  end
end
