# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::FinderConcern do
  describe '.representative' do
    context 'with an instance actor using an invalid legacy username' do
      let(:legacy_value) { 'localhost:3000' }

      before { Account.find(Account::INSTANCE_ACTOR_ID).update_attribute(:username, legacy_value) }

      it 'updates the username to the new value' do
        expect { Account.representative }
          .to change { Account.find(Account::INSTANCE_ACTOR_ID).username }.from(legacy_value).to('mastodon.internal')
      end
    end

    context 'without an instance actor' do
      before { Account.find(Account::INSTANCE_ACTOR_ID).destroy! }

      it 'creates an instance actor' do
        expect { Account.representative }
          .to change(Account.where(id: Account::INSTANCE_ACTOR_ID), :count).from(0).to(1)
      end
    end

    context 'with a correctly loaded instance actor' do
      let(:instance_actor) { Account.find(Account::INSTANCE_ACTOR_ID) }

      it 'returns the instance actor record' do
        expect(Account.representative)
          .to eq(instance_actor)
      end
    end
  end

  describe 'local finders' do
    let!(:account) { Fabricate(:account, username: 'Alice') }

    describe '.find_local' do
      it 'returns case-insensitive result' do
        expect(Account.find_local('alice')).to eq(account)
      end

      it 'returns correctly cased result' do
        expect(Account.find_local('Alice')).to eq(account)
      end

      it 'returns nil without a match' do
        expect(Account.find_local('a_ice')).to be_nil
      end

      it 'returns nil for regex style username value' do
        expect(Account.find_local('al%')).to be_nil
      end

      it 'returns nil for nil username value' do
        expect(Account.find_local(nil)).to be_nil
      end

      it 'returns nil for blank username value' do
        expect(Account.find_local('')).to be_nil
      end
    end

    describe '.find_local!' do
      it 'returns matching result' do
        expect(Account.find_local!('alice')).to eq(account)
      end

      it 'raises on non-matching result' do
        expect { Account.find_local!('missing') }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises with blank username' do
        expect { Account.find_local!('') }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises with nil username' do
        expect { Account.find_local!(nil) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'remote finders' do
    let!(:account) { Fabricate(:account, username: 'Alice', domain: 'mastodon.social') }

    describe '.find_remote' do
      it 'returns exact match result' do
        expect(Account.find_remote('alice', 'mastodon.social')).to eq(account)
      end

      it 'returns case-insensitive result' do
        expect(Account.find_remote('ALICE', 'MASTODON.SOCIAL')).to eq(account)
      end

      it 'returns nil when username does not match' do
        expect(Account.find_remote('a_ice', 'mastodon.social')).to be_nil
      end

      it 'returns nil when domain does not match' do
        expect(Account.find_remote('alice', 'm_stodon.social')).to be_nil
      end

      it 'returns nil for regex style domain value' do
        expect(Account.find_remote('alice', 'm%')).to be_nil
      end

      it 'returns nil for nil username value' do
        expect(Account.find_remote(nil, 'domain')).to be_nil
      end

      it 'returns nil for blank username value' do
        expect(Account.find_remote('', 'domain')).to be_nil
      end
    end

    describe '.find_remote!' do
      it 'returns matching result' do
        expect(Account.find_remote!('alice', 'mastodon.social')).to eq(account)
      end

      it 'raises on non-matching result' do
        expect { Account.find_remote!('missing', 'mastodon.host') }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises with blank username' do
        expect { Account.find_remote!('', '') }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises with nil username' do
        expect { Account.find_remote!(nil, nil) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
