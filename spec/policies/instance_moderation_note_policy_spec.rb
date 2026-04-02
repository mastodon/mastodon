# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstanceModerationNotePolicy do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user).account }
  let(:account) { Fabricate(:account) }

  permissions :create? do
    context 'when admin' do
      it { is_expected.to permit(admin, InstanceModerationNote.new) }
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, InstanceModerationNote.new) }
    end
  end

  permissions :destroy? do
    context 'when owner of note' do
      let(:note) { Fabricate :instance_moderation_note, account: account }

      it { is_expected.to permit(account, note) }
    end

    context 'when not owner of note' do
      context 'when admin and overrides' do
        let(:note) { Fabricate :instance_moderation_note }

        it { is_expected.to permit(admin, note) }
      end

      context 'when admin and does not override' do
        let(:note) { Fabricate :instance_moderation_note, account: Fabricate(:admin_user).account }

        it { is_expected.to_not permit(admin, note) }
      end
    end
  end
end
