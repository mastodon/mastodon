# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusGroupValidator, type: :validator do
  describe '#validate' do
    before do
      subject.validate(status)
    end

    context 'when the status does not have group visibility and is not part of a group' do
      let(:account) { Fabricate(:account) }
      let(:status)  { Status.new(account: account, text: 'test', visibility: :unlisted) }

      it 'does not add any error' do
        expect(status.errors.to_a.empty?).to eq true
      end
    end

    context 'when the status is a group post by a group member' do
      let(:group)   { Fabricate(:group) }
      let(:account) { Fabricate(:group_membership, group: group).account }
      let(:status)  { Status.new(account: account, text: 'test', visibility: :group, group: group) }

      it 'does not add any error' do
        expect(status.errors.to_a.empty?).to eq true
      end
    end

    context 'when a group member replies in-group to a group post' do
      let(:group)   { Fabricate(:group) }
      let(:account) { Fabricate(:group_membership, group: group).account }
      let(:thread)  { Fabricate(:status, group: group, account: account, visibility: :group, text: 'test') }
      let(:status)  { Status.new(account: account, text: 'test', group: group, visibility: :group, thread: thread) }

      it 'does not add any error' do
        expect(status.errors.to_a.empty?).to eq true
      end
    end

    context 'when the status is a group post made by someone known to not be a group member' do
      let(:group)   { Fabricate(:group, domain: nil) }
      let(:account) { Fabricate(:account, domain: nil) }
      let(:status)  { Status.new(account: account, text: 'test', visibility: :group, group: group) }

      it 'adds an error' do
        expect(status.errors[:base]).to include(I18n.t('statuses.group_errors.invalid_membership'))
      end
    end

    context 'when the status has group visibility but no attached group' do
      let(:group)   { Fabricate(:group) }
      let(:account) { Fabricate(:group_membership, group: group).account }
      let(:status)  { Status.new(account: account, text: 'test', visibility: :group) }

      it 'adds an error' do
        expect(status.errors[:base]).to include(I18n.t('statuses.group_errors.invalid_group_id'))
      end
    end

    context 'when the status is attached to a group but does not have group visibility' do
      let(:group)   { Fabricate(:group) }
      let(:account) { Fabricate(:group_membership, group: group).account }
      let(:status)  { Status.new(account: account, text: 'test', group: group, visibility: :unlisted) }

      it 'adds an error' do
        expect(status.errors[:base]).to include(I18n.t('statuses.group_errors.invalid_visibility'))
      end
    end

    context 'when replying in-group to a non-group status' do
      let(:group)   { Fabricate(:group) }
      let(:account) { Fabricate(:group_membership, group: group).account }
      let(:thread)  { Fabricate(:status) }
      let(:status)  { Status.new(account: account, text: 'test', group: group, visibility: :group, thread: thread) }

      it 'adds an error' do
        expect(status.errors[:base]).to include(I18n.t('statuses.group_errors.invalid_reply'))
      end
    end

    context 'when a group member replies in-group to a post made in a different group' do
      let(:group)         { Fabricate(:group) }
      let(:other_group)   { Fabricate(:group) }
      let(:account)       { Fabricate(:group_membership, group: group).account }
      let(:other_account) { Fabricate(:group_membership, group: other_group).account }
      let(:thread)        { Fabricate(:status, group: other_group, account: other_account, visibility: :group, text: 'test') }
      let(:status)        { Status.new(account: account, text: 'test', group: group, visibility: :group, thread: thread) }

      it 'adds an error' do
        expect(status.errors[:base]).to include(I18n.t('statuses.group_errors.invalid_reply'))
      end
    end

    context 'when replying out-of-group to a group post' do
      let(:group)   { Fabricate(:group) }
      let(:account) { Fabricate(:group_membership, group: group).account }
      let(:thread)  { Fabricate(:status, group: group, account: account, visibility: :group, text: 'test') }
      let(:status)  { Status.new(account: account, text: 'test', visibility: :unlisted, thread: thread) }

      it 'adds an error' do
        expect(status.errors[:base]).to include(I18n.t('statuses.group_errors.invalid_reply'))
      end
    end
  end
end
