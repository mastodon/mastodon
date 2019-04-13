# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe AccountModerationNotePolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, admin: true).account }
  let(:john)    { Fabricate(:user).account }

  permissions :create? do
    context 'staff' do
      it 'grants to create' do
        expect(subject).to permit(admin, AccountModerationNotePolicy)
      end
    end

    context 'not staff' do
      it 'denies to create' do
        expect(subject).to_not permit(john, AccountModerationNotePolicy)
      end
    end
  end

  permissions :destroy? do
    let(:account_moderation_note) do
      Fabricate(:account_moderation_note,
                account: john,
                target_account: Fabricate(:account))
    end

    context 'admin' do
      it 'grants to destroy' do
        expect(subject).to permit(admin, AccountModerationNotePolicy)
      end
    end

    context 'owner' do
      it 'grants to destroy' do
        expect(subject).to permit(john, account_moderation_note)
      end
    end

    context 'neither admin nor owner' do
      let(:kevin) { Fabricate(:user).account }

      it 'denies to destroy' do
        expect(subject).to_not permit(kevin, account_moderation_note)
      end
    end
  end
end
