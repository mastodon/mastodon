# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::FollowerHashing do
  let(:null_digest_value) { '0000000000000000000000000000000000000000000000000000000000000000' }

  describe '#remote_followers_hash' do
    let(:me) { Fabricate(:account, username: 'Me') }
    let(:remote_alice) { Fabricate(:account, username: 'alice', domain: 'example.org', uri: 'https://example.org/users/alice') }
    let(:remote_bob) { Fabricate(:account, username: 'bob', domain: 'example.org', uri: 'https://example.org/users/bob') }
    let(:remote_instance_actor) { Fabricate(:account, username: 'instance-actor', domain: 'example.org', uri: 'https://example.org') }
    let(:remote_eve) { Fabricate(:account, username: 'eve', domain: 'foo.org', uri: 'https://foo.org/users/eve') }

    before do
      remote_alice.follow!(me)
      remote_bob.follow!(me)
      remote_instance_actor.follow!(me)
      remote_eve.follow!(me)
      me.follow!(remote_alice)
    end

    it 'returns correct hash for remote domains' do
      expect(me.remote_followers_hash('https://example.org/'))
        .to eq '20aecbe774b3d61c25094370baf370012b9271c5b172ecedb05caff8d79ef0c7'
      expect(me.remote_followers_hash('https://foo.org/'))
        .to eq 'ccb9c18a67134cfff9d62c7f7e7eb88e6b803446c244b84265565f4eba29df0e'
      expect(me.remote_followers_hash('https://foo.org.evil.com/'))
        .to eq null_digest_value
      expect(me.remote_followers_hash('https://foo'))
        .to eq null_digest_value
    end

    it 'invalidates cache as needed when removing or adding followers' do
      expect(me.remote_followers_hash('https://example.org/'))
        .to eq '20aecbe774b3d61c25094370baf370012b9271c5b172ecedb05caff8d79ef0c7'

      remote_instance_actor.unfollow!(me)
      expect(me.remote_followers_hash('https://example.org/'))
        .to eq '707962e297b7bd94468a21bc8e506a1bcea607a9142cd64e27c9b106b2a5f6ec'

      remote_alice.unfollow!(me)
      expect(me.remote_followers_hash('https://example.org/'))
        .to eq '241b00794ce9b46aa864f3220afadef128318da2659782985bac5ed5bd436bff'

      remote_alice.follow!(me)
      expect(me.remote_followers_hash('https://example.org/'))
        .to eq '707962e297b7bd94468a21bc8e506a1bcea607a9142cd64e27c9b106b2a5f6ec'
    end
  end

  describe '#local_followers_hash' do
    let(:me) { Fabricate(:account, username: 'Me') }
    let(:remote_alice) { Fabricate(:account, username: 'alice', domain: 'example.org', uri: 'https://example.org/users/alice') }

    before { me.follow!(remote_alice) }

    it 'returns correct hash for local users' do
      expect(remote_alice.local_followers_hash)
        .to eq Digest::SHA256.hexdigest(ActivityPub::TagManager.instance.uri_for(me))
    end

    it 'invalidates cache as needed when removing or adding followers' do
      expect(remote_alice.local_followers_hash)
        .to eq Digest::SHA256.hexdigest(ActivityPub::TagManager.instance.uri_for(me))

      me.unfollow!(remote_alice)
      expect(remote_alice.local_followers_hash)
        .to eq null_digest_value

      me.follow!(remote_alice)
      expect(remote_alice.local_followers_hash)
        .to eq Digest::SHA256.hexdigest(ActivityPub::TagManager.instance.uri_for(me))
    end

    context 'when using numeric ID based scheme' do
      let(:me) { Fabricate(:account, username: 'Me', id_scheme: :numeric_ap_id) }

      it 'returns correct hash for local users' do
        expect(remote_alice.local_followers_hash)
          .to eq Digest::SHA256.hexdigest(ActivityPub::TagManager.instance.uri_for(me))
      end

      it 'invalidates cache as needed when removing or adding followers' do
        expect(remote_alice.local_followers_hash)
          .to eq Digest::SHA256.hexdigest(ActivityPub::TagManager.instance.uri_for(me))

        me.unfollow!(remote_alice)
        expect(remote_alice.local_followers_hash)
          .to eq null_digest_value

        me.follow!(remote_alice)
        expect(remote_alice.local_followers_hash)
          .to eq Digest::SHA256.hexdigest(ActivityPub::TagManager.instance.uri_for(me))
      end
    end
  end
end
