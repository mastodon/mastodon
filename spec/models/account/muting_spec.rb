# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Muting do
  let(:account) { Fabricate(:account) }
  let(:target_account) { Fabricate(:account) }

  describe 'Associations' do
    subject { Fabricate.build :account }

    it { is_expected.to have_many(:mute_relationships).class_name(Mute).dependent(:destroy).inverse_of(:account).with_foreign_key(:account_id) }
    it { is_expected.to have_many(:muted_by_relationships).class_name(Mute).dependent(:destroy).inverse_of(:target_account).with_foreign_key(:target_account_id) }

    it { is_expected.to have_many(:muting).through(:mute_relationships).source(:target_account) }
    it { is_expected.to have_many(:muted_by).through(:muted_by_relationships).source(:account) }
  end

  describe '#mute!' do
    subject { account.mute!(target_account, notifications: arg_notifications) }

    context 'when Mute does not exist yet' do
      context 'when arg :notifications is nil' do
        let(:arg_notifications) { nil }

        it 'creates Mute, and returns Mute' do
          expect { expect(subject).to be_a(Mute) }
            .to change { account.mute_relationships.count }.by 1
        end
      end

      context 'when arg :notifications is false' do
        let(:arg_notifications) { false }

        it 'creates Mute, and returns Mute' do
          expect { expect(subject).to be_a(Mute) }
            .to change { account.mute_relationships.count }.by 1
        end
      end

      context 'when arg :notifications is true' do
        let(:arg_notifications) { true }

        it 'creates Mute, and returns Mute' do
          expect { expect(subject).to be_a(Mute) }
            .to change { account.mute_relationships.count }.by 1
        end
      end
    end

    context 'when Mute already exists' do
      before do
        account.mute_relationships << mute
      end

      let(:mute) do
        Fabricate(:mute,
                  account: account,
                  target_account: target_account,
                  hide_notifications: hide_notifications)
      end

      context 'when mute.hide_notifications is true' do
        let(:hide_notifications) { true }

        context 'when arg :notifications is nil' do
          let(:arg_notifications) { nil }

          it 'returns Mute without updating mute.hide_notifications' do
            expect { expect(subject).to be_a(Mute) }
              .to_not change { mute.reload.hide_notifications? }.from(true)
          end
        end

        context 'when arg :notifications is false' do
          let(:arg_notifications) { false }

          it 'returns Mute, and updates mute.hide_notifications false' do
            expect { expect(subject).to be_a(Mute) }
              .to change { mute.reload.hide_notifications? }.from(true).to(false)
          end
        end

        context 'when arg :notifications is true' do
          let(:arg_notifications) { true }

          it 'returns Mute without updating mute.hide_notifications' do
            expect { expect(subject).to be_a(Mute) }
              .to_not change { mute.reload.hide_notifications? }.from(true)
          end
        end
      end

      context 'when mute.hide_notifications is false' do
        let(:hide_notifications) { false }

        context 'when arg :notifications is nil' do
          let(:arg_notifications) { nil }

          it 'returns Mute, and updates mute.hide_notifications true' do
            expect { expect(subject).to be_a(Mute) }
              .to change { mute.reload.hide_notifications? }.from(false).to(true)
          end
        end

        context 'when arg :notifications is false' do
          let(:arg_notifications) { false }

          it 'returns Mute without updating mute.hide_notifications' do
            expect { expect(subject).to be_a(Mute) }
              .to_not change { mute.reload.hide_notifications? }.from(false)
          end
        end

        context 'when arg :notifications is true' do
          let(:arg_notifications) { true }

          it 'returns Mute, and updates mute.hide_notifications true' do
            expect { expect(subject).to be_a(Mute) }
              .to change { mute.reload.hide_notifications? }.from(false).to(true)
          end
        end
      end
    end
  end

  describe '#unmute!' do
    subject { account.unmute!(target_account) }

    context 'when muting target_account' do
      before { account.mute_relationships.create(target_account: target_account) }

      it 'returns destroyed Mute' do
        expect(subject)
          .to be_a(Mute)
          .and be_destroyed
      end
    end

    context 'when not muting target_account' do
      it { is_expected.to be_nil }
    end
  end

  describe '#muting?' do
    subject { account.muting?(target_account) }

    context 'when muting target_account' do
      let(:mute) { Fabricate(:mute, account: account, target_account: target_account) }

      before { account.mute_relationships << mute }

      it 'returns true' do
        expect { expect(subject).to be(true) }
          .to execute_queries
      end

      context 'when relations are preloaded' do
        before { account.preload_relations!([target_account.id]) }

        it 'does not query the database to get the result' do
          expect { expect(subject).to be(true) }
            .to_not execute_queries
        end
      end
    end

    context 'when not muting target_account' do
      it { is_expected.to be(false) }
    end
  end
end
