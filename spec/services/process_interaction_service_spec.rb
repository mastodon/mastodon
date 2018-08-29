require 'rails_helper'

RSpec.describe ProcessInteractionService, type: :service do
  let(:receiver) { Fabricate(:user, email: 'alice@example.com', account: Fabricate(:account, username: 'alice')).account }
  let(:sender)   { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }
  let(:remote_sender) { Fabricate(:account, username: 'carol', domain: 'localdomain.com', uri: 'https://webdomain.com/users/carol') }

  subject { ProcessInteractionService.new }

  describe 'status delete slap' do
    let(:remote_status) { Fabricate(:status, account: remote_sender) }
    let(:envelope) { OStatus2::Salmon.new.pack(payload, sender.keypair) }
    let(:payload) {
      <<~XML
        <entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
          <author>
            <email>carol@localdomain.com</email>
            <name>carol</name>
            <uri>https://webdomain.com/users/carol</uri>
          </author>

          <id>#{remote_status.id}</id>
          <activity:verb>http://activitystrea.ms/schema/1.0/delete</activity:verb>
        </entry>
      XML
    }

    before do
      receiver.update(locked: true)
      remote_sender.update(private_key: sender.private_key, public_key: remote_sender.public_key)
    end

    it 'deletes a record' do
      expect(RemovalWorker).to receive(:perform_async).with(remote_status.id)
      subject.call(envelope, receiver)
    end
  end

  describe 'follow request slap' do
    before do
      receiver.update(locked: true)

      payload = <<XML
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
  <author>
    <name>bob</name>
    <uri>https://cb6e6126.ngrok.io/users/bob</uri>
  </author>

  <id>someIdHere</id>
  <activity:verb>http://activitystrea.ms/schema/1.0/request-friend</activity:verb>
</entry>
XML

      envelope = OStatus2::Salmon.new.pack(payload, sender.keypair)
      subject.call(envelope, receiver)
    end

    it 'creates a record' do
      expect(FollowRequest.find_by(account: sender, target_account: receiver)).to_not be_nil
    end
  end

  describe 'follow request slap from known remote user identified by email' do
    before do
      receiver.update(locked: true)
      # Copy already-generated key
      remote_sender.update(private_key: sender.private_key, public_key: remote_sender.public_key)

      payload = <<XML
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
  <author>
    <email>carol@localdomain.com</email>
    <name>carol</name>
    <uri>https://webdomain.com/users/carol</uri>
  </author>

  <id>someIdHere</id>
  <activity:verb>http://activitystrea.ms/schema/1.0/request-friend</activity:verb>
</entry>
XML

      envelope = OStatus2::Salmon.new.pack(payload, remote_sender.keypair)
      subject.call(envelope, receiver)
    end

    it 'creates a record' do
      expect(FollowRequest.find_by(account: remote_sender, target_account: receiver)).to_not be_nil
    end
  end

  describe 'follow request authorization slap' do
    before do
      receiver.update(locked: true)
      FollowRequest.create(account: sender, target_account: receiver)

      payload = <<XML
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
  <author>
    <name>alice</name>
    <uri>https://cb6e6126.ngrok.io/users/alice</uri>
  </author>

  <id>someIdHere</id>
  <activity:verb>http://activitystrea.ms/schema/1.0/authorize</activity:verb>
</entry>
XML

      envelope = OStatus2::Salmon.new.pack(payload, receiver.keypair)
      subject.call(envelope, sender)
    end

    it 'creates a follow relationship' do
      expect(Follow.find_by(account: sender, target_account: receiver)).to_not be_nil
    end

    it 'removes the follow request' do
      expect(FollowRequest.find_by(account: sender, target_account: receiver)).to be_nil
    end
  end

  describe 'follow request rejection slap' do
    before do
      receiver.update(locked: true)
      FollowRequest.create(account: sender, target_account: receiver)

      payload = <<XML
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
  <author>
    <name>alice</name>
    <uri>https://cb6e6126.ngrok.io/users/alice</uri>
  </author>

  <id>someIdHere</id>
  <activity:verb>http://activitystrea.ms/schema/1.0/reject</activity:verb>
</entry>
XML

      envelope = OStatus2::Salmon.new.pack(payload, receiver.keypair)
      subject.call(envelope, sender)
    end

    it 'does not create a follow relationship' do
      expect(Follow.find_by(account: sender, target_account: receiver)).to be_nil
    end

    it 'removes the follow request' do
      expect(FollowRequest.find_by(account: sender, target_account: receiver)).to be_nil
    end
  end
end
