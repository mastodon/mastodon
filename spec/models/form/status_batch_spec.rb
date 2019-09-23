require 'rails_helper'

describe Form::StatusBatch do
  let(:form) { Form::StatusBatch.new(action: action, status_ids: status_ids) }
  let(:status) { Fabricate(:status) }

  describe 'with nsfw action' do
    let(:status_ids) { [status.id, nonsensitive_status.id, sensitive_status.id] }
    let(:nonsensitive_status) { Fabricate(:status, sensitive: false) }
    let(:sensitive_status) { Fabricate(:status, sensitive: true) }
    let!(:shown_media_attachment) { Fabricate(:media_attachment, status: nonsensitive_status) }
    let!(:hidden_media_attachment) { Fabricate(:media_attachment, status: sensitive_status) }

    context 'nsfw_on' do
      let(:action) { 'nsfw_on' }

      it { expect(form.save).to be true }
      it { expect { form.save }.to change { nonsensitive_status.reload.sensitive }.from(false).to(true) }
      it { expect { form.save }.not_to change { sensitive_status.reload.sensitive } }
      it { expect { form.save }.not_to change { status.reload.sensitive } }
    end

    context 'nsfw_off' do
      let(:action) { 'nsfw_off' }

      it { expect(form.save).to be true }
      it { expect { form.save }.to change { sensitive_status.reload.sensitive }.from(true).to(false) }
      it { expect { form.save }.not_to change { nonsensitive_status.reload.sensitive } }
      it { expect { form.save }.not_to change { status.reload.sensitive } }
    end
  end

  describe 'with delete action' do
    let(:status_ids) { [status.id] }
    let(:action) { 'delete' }
    let!(:another_status) { Fabricate(:status) }

    before do
      allow(RemovalWorker).to receive(:perform_async)
    end

    it 'call RemovalWorker' do
      form.save
      expect(RemovalWorker).to have_received(:perform_async).with(status.id, immediate: true)
    end

    it 'do not call RemovalWorker' do
      form.save
      expect(RemovalWorker).not_to have_received(:perform_async).with(another_status.id, immediate: true)
    end
  end
end
