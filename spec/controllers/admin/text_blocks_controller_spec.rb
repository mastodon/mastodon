# frozen_string_literal: true

require 'rails_helper'

describe Admin::TextBlocksController, type: :controller do
  describe 'POST #create' do
    subject { post :create, params: { text_block: { text: 'text', severity: 'silence' } } }

    context 'when authorized' do
      before { sign_in Fabricate(:user, admin: true) }

      context 'when text block creation fails' do
        before do
          allow_any_instance_of(TextBlock).to receive(:save).and_return(false)
        end

        it { is_expected.to render_template :index }
      end

      it 'creates text block' do
        subject

        expect(Admin::ActionLog.where(
          action: 'create',
          target: TextBlock.find_by!(text: 'text', severity: 'silence')
        )).to exist
      end

      it 'notes successful creation' do
        subject
        expect(flash[:notice]).to eq I18n.t('admin.text_blocks.created')
      end

      it { is_expected.to redirect_to action: :index }
    end

    context 'when unauthorized' do
      before { sign_in Fabricate(:user, moderator: true) }
      it { is_expected.to have_http_status :forbidden }
    end
  end

  describe 'POST #update' do
    let(:text_block) { Fabricate(:text_block) }
    subject { patch :update, params: { id: text_block, text_block: { text: 'text', severity: 'silence' } } }

    context 'when authorized' do
      before { sign_in Fabricate(:user, admin: true) }

      context 'when text block update fails' do
        before do
          allow_any_instance_of(TextBlock).to receive(:update).and_return(false)
        end

        it { is_expected.to render_template :show }
      end

      it 'updates text block' do
        subject

        text_block.reload
        expect(text_block.text).to eq 'text'
        expect(text_block.severity).to eq 'silence'
        expect(Admin::ActionLog.where(action: 'update', target: text_block)).to exist
      end

      it 'notes successful creation' do
        subject
        expect(flash[:notice]).to eq I18n.t('admin.text_blocks.updated')
      end

      it { is_expected.to redirect_to action: :index }
    end

    context 'when unauthorized' do
      before { sign_in Fabricate(:user, moderator: true) }
      it { is_expected.to have_http_status :forbidden }
    end
  end

  describe 'DELETE #destroy' do
    let(:text_block) { Fabricate(:text_block) }
    subject { delete :destroy, params: { id: text_block } }

    context 'when authorized' do
      before { sign_in Fabricate(:user, admin: true) }

      context 'when text block deletion fails' do
        before do
          allow_any_instance_of(TextBlock).to receive(:destroy) do |text_block|
            text_block.errors.add :base
            false
          end
        end

        it 'alerts deletion failure' do
          subject
          expect(flash[:alert]).to eq 'is invalid'
        end
      end

      it 'destroys text block' do
        subject
        expect{ text_block.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(Admin::ActionLog.where(action: 'destroy', target: text_block)).to exist
      end

      it 'notes successful deletion' do
        subject
        expect(flash[:notice]).to eq I18n.t('admin.text_blocks.destroyed')
      end

      it { is_expected.to redirect_to action: :index }
    end

    context 'when unauthorized' do
      before { sign_in Fabricate(:user, moderator: true) }
      it { is_expected.to have_http_status :forbidden }
    end
  end
end
