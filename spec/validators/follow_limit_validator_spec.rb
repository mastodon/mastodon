# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowLimitValidator, type: :validator do
  describe '#validate' do
    before do
      allow_any_instance_of(described_class).to receive(:limit_reached?).with(account) do
        limit_reached
      end

      described_class.new.validate(follow)
    end

    let(:follow)  { double(account: account, errors: errors) }
    let(:errors)  { double(add: nil) }
    let(:account) { double(nil?: _nil, local?: local, following_count: 0, followers_count: 0) }
    let(:_nil)    { true }
    let(:local)   { false }

    context 'with follow.account.nil? || !follow.account.local?' do
      let(:_nil)    { true }

      it 'not calls errors.add' do
        expect(errors).to_not have_received(:add).with(:base, any_args)
      end
    end

    context 'with !(follow.account.nil? || !follow.account.local?)' do
      let(:_nil)    { false }
      let(:local)   { true }

      context 'when limit_reached?' do
        let(:limit_reached) { true }

        it 'calls errors.add' do
          expect(errors).to have_received(:add)
            .with(:base, I18n.t('users.follow_limit_reached', limit: FollowLimitValidator::LIMIT))
        end
      end

      context 'with !limit_reached?' do
        let(:limit_reached) { false }

        it 'not calls errors.add' do
          expect(errors).to_not have_received(:add).with(:base, any_args)
        end
      end
    end
  end
end
