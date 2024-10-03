# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status::ThreadingConcern do
  describe '#ancestors' do
    let!(:alice)  { Fabricate(:account, username: 'alice') }
    let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com') }
    let!(:jeff)   { Fabricate(:account, username: 'jeff') }
    let!(:status) { Fabricate(:status, account: alice) }
    let!(:reply_to_status) { Fabricate(:status, thread: status, account: jeff) }
    let!(:reply_to_first_reply) { Fabricate(:status, thread: reply_to_status, account: bob) }
    let!(:reply_to_second_reply) { Fabricate(:status, thread: reply_to_first_reply, account: alice) }
    let!(:viewer) { Fabricate(:account, username: 'viewer') }

    it 'returns conversation history' do
      expect(reply_to_second_reply.ancestors(4)).to include(status, reply_to_status, reply_to_first_reply)
    end

    it 'does not return conversation history user is not allowed to see' do
      reply_to_status.update(visibility: :private)
      status.update(visibility: :direct)

      expect(reply_to_second_reply.ancestors(4, viewer)).to_not include(reply_to_status, status)
    end

    it 'does not return conversation history from blocked users' do
      viewer.block!(jeff)
      expect(reply_to_second_reply.ancestors(4, viewer)).to_not include(reply_to_status)
    end

    it 'does not return conversation history from muted users' do
      viewer.mute!(jeff)
      expect(reply_to_second_reply.ancestors(4, viewer)).to_not include(reply_to_status)
    end

    it 'does not return conversation history from silenced and not followed users' do
      jeff.silence!
      expect(reply_to_second_reply.ancestors(4, viewer)).to_not include(reply_to_status)
    end

    it 'does not return conversation history from blocked domains' do
      viewer.block_domain!('example.com')
      expect(reply_to_second_reply.ancestors(4, viewer)).to_not include(reply_to_first_reply)
    end

    it 'ignores deleted records' do
      first_status  = Fabricate(:status, account: bob)
      second_status = Fabricate(:status, thread: first_status, account: alice)

      # Create cache and delete cached record
      second_status.ancestors(4)
      first_status.destroy

      expect(second_status.ancestors(4)).to eq([])
    end

    it 'can return more records than previously requested' do
      first_status  = Fabricate(:status, account: bob)
      second_status = Fabricate(:status, thread: first_status, account: alice)
      third_status = Fabricate(:status, thread: second_status, account: alice)

      # Create cache
      second_status.ancestors(1)

      expect(third_status.ancestors(2)).to eq([first_status, second_status])
    end

    it 'can return fewer records than previously requested' do
      first_status  = Fabricate(:status, account: bob)
      second_status = Fabricate(:status, thread: first_status, account: alice)
      third_status = Fabricate(:status, thread: second_status, account: alice)

      # Create cache
      second_status.ancestors(2)

      expect(third_status.ancestors(1)).to eq([second_status])
    end
  end

  describe '#descendants' do
    let!(:alice)  { Fabricate(:account, username: 'alice') }
    let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com') }
    let!(:jeff)   { Fabricate(:account, username: 'jeff') }
    let!(:status) { Fabricate(:status, account: alice) }
    let!(:reply_to_status_from_alice) { Fabricate(:status, thread: status, account: alice) }
    let!(:reply_to_status_from_bob) { Fabricate(:status, thread: status, account: bob) }
    let!(:reply_to_alice_reply_from_jeff) { Fabricate(:status, thread: reply_to_status_from_alice, account: jeff) }
    let!(:viewer) { Fabricate(:account, username: 'viewer') }

    it 'returns replies' do
      expect(status.descendants(4)).to include(reply_to_status_from_alice, reply_to_status_from_bob, reply_to_alice_reply_from_jeff)
    end

    it 'does not return replies user is not allowed to see' do
      reply_to_status_from_alice.update(visibility: :private)
      reply_to_alice_reply_from_jeff.update(visibility: :direct)

      expect(status.descendants(4, viewer)).to_not include(reply_to_status_from_alice, reply_to_alice_reply_from_jeff)
    end

    it 'does not return replies from blocked users' do
      viewer.block!(jeff)
      expect(status.descendants(4, viewer)).to_not include(reply_to_alice_reply_from_jeff)
    end

    it 'does not return replies from muted users' do
      viewer.mute!(jeff)
      expect(status.descendants(4, viewer)).to_not include(reply_to_alice_reply_from_jeff)
    end

    it 'does not return replies from silenced and not followed users' do
      jeff.silence!
      expect(status.descendants(4, viewer)).to_not include(reply_to_alice_reply_from_jeff)
    end

    it 'does not return replies from blocked domains' do
      viewer.block_domain!('example.com')
      expect(status.descendants(4, viewer)).to_not include(reply_to_status_from_bob)
    end

    it 'promotes self-replies to the top while leaving the rest in order' do
      a = Fabricate(:status, account: alice)
      d = Fabricate(:status, account: jeff, thread: a)
      e = Fabricate(:status, account: bob, thread: d)
      c = Fabricate(:status, account: alice, thread: a)
      f = Fabricate(:status, account: bob, thread: c)

      expect(a.descendants(20)).to eq [c, d, e, f]
    end
  end
end
