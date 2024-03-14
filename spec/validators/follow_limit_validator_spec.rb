# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowLimitValidator do
  describe '#validate' do
    context 'with a nil account' do
      it 'does not add validation errors to base' do
        follow = Fabricate.build(:follow, account: nil)

        follow.valid?

        expect(follow.errors[:base]).to be_empty
      end
    end

    context 'with a non-local account' do
      it 'does not add validation errors to base' do
        follow = Fabricate.build(:follow, account: Account.new(domain: 'host.example'))

        follow.valid?

        expect(follow.errors[:base]).to be_empty
      end
    end

    context 'with a local account' do
      let(:account) { Account.new }

      context 'when the followers count is under the limit' do
        before do
          allow(account).to receive(:following_count).and_return(described_class::LIMIT - 100)
        end

        it 'does not add validation errors to base' do
          follow = Fabricate.build(:follow, account: account)

          follow.valid?

          expect(follow.errors[:base]).to be_empty
        end
      end

      context 'when the following count is over the limit' do
        before do
          allow(account).to receive(:following_count).and_return(described_class::LIMIT + 100)
        end

        context 'when the followers count is low' do
          before do
            allow(account).to receive(:followers_count).and_return(10)
          end

          it 'adds validation errors to base' do
            follow = Fabricate.build(:follow, account: account)

            follow.valid?

            expect(follow.errors[:base]).to include(I18n.t('users.follow_limit_reached', limit: described_class::LIMIT))
          end
        end

        context 'when the followers count is high' do
          before do
            allow(account).to receive(:followers_count).and_return(100_000)
          end

          it 'does not add validation errors to base' do
            follow = Fabricate.build(:follow, account: account)

            follow.valid?

            expect(follow.errors[:base]).to be_empty
          end
        end
      end
    end
  end
end
