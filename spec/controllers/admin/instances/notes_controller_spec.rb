# frozen_string_literal: true

require 'rails_helper'

describe Admin::Instances::NotesController do
  include ActionView::RecordIdentifier

  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
  let(:instance_domain) { 'mastodon.example' }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #create' do
    subject { post :create, params: params }

    let(:params) { { instance_id: instance_domain, instance_note: { content: 'test content' } } }

    it 'creates an instance note' do
      expect { subject }.to change(InstanceNote, :count).by(1)
      expect(response).to redirect_to admin_instance_path(instance_domain, anchor: dom_id(InstanceNote.last))
    end

    context 'when content is too short' do
      let(:params) { { instance_id: instance_domain, instance_note: { content: '' } } }

      it 'renders admin/instances/show' do
        expect { subject }.to_not change(InstanceNote, :count)
        expect(subject).to render_template 'admin/instances/show'
      end
    end

    context 'when content is too long' do
      let(:params) { { instance_id: instance_domain, instance_note: { content: 'test' * ReportNote::CONTENT_SIZE_LIMIT } } }

      it 'renders admin/instances/show' do
        expect { subject }.to_not change(InstanceNote, :count)
        expect(subject).to render_template 'admin/instances/show'
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { instance_id: instance_domain, id: instance_note.id } }

    let!(:instance_note) { Fabricate(:instance_note, domain: instance_domain) }

    it 'deletes note' do
      expect { subject }.to change(InstanceNote, :count).by(-1)
      expect(response).to redirect_to admin_instance_path(instance_domain, anchor: 'instance_notes')
    end
  end
end
