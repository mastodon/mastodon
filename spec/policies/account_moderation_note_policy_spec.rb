# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe AccountModerationNotePolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :create? do
    context 'when staff' do
      it 'grants to create' do
        expect(subject).to permit(admin, described_class)
      end
    end

    context 'when not staff' do
      it 'denies to create' do
        expect(subject).to_not permit(john, described_class)
      end
    end
  end

  permissions :destroy? do
    let(:account_moderation_note) do
      Fabricate(:account_moderation_note,
                account: john,
                target_account: Fabricate(:account))
    end

    context 'when admin' do
      it 'grants to destroy' do
        expect(subject).to permit(admin, account_moderation_note)
      end
    end

    context 'when owner' do
      it 'grants to destroy' do
        expect(subject).to permit(john, account_moderation_note)
      end
    end

    context 'when neither admin nor owner' do
      let(:kevin) { Fabricate(:account) }

      it 'denies to destroy' do
        expect(subject).to_not permit(kevin, account_moderation_note)
      end
    end
  end
end
