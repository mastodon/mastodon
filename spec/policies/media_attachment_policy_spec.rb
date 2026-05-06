# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaAttachmentPolicy do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user).account }
  let(:account) { Fabricate(:account) }

  permissions :download? do
    context 'when attachment is on private discarded status' do
      let(:media_attachment) { Fabricate.build :media_attachment, status: Fabricate.build(:status, deleted_at: 5.days.ago, visibility: :private) }

      context 'when admin' do
        it { is_expected.to permit(admin, media_attachment) }
      end

      context 'when not admin' do
        it { is_expected.to_not permit(account, media_attachment) }
      end
    end

    context 'when attachment is on public status' do
      let(:media_attachment) { Fabricate.build :media_attachment, status: Fabricate.build(:status, visibility: :public) }

      context 'when admin' do
        it { is_expected.to permit(admin, media_attachment) }
      end

      context 'when not admin' do
        it { is_expected.to permit(account, media_attachment) }
      end
    end
  end
end
