require 'rails_helper'

RSpec.describe ActivityPub::ProcessAccountService, type: :service do
  subject { described_class.new }

  context 'property values' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        attachment: [
          { type: 'PropertyValue', name: 'Pronouns', value: 'They/them' },
          { type: 'PropertyValue', name: 'Occupation', value: 'Unit test' },
        ],
      }.with_indifferent_access
    end

    it 'parses out of attachment' do
      account = subject.call('alice', 'example.com', payload)
      expect(account.fields).to be_a Array
      expect(account.fields.size).to eq 2
      expect(account.fields[0]).to be_a Account::Field
      expect(account.fields[0].name).to eq 'Pronouns'
      expect(account.fields[0].value).to eq 'They/them'
      expect(account.fields[1]).to be_a Account::Field
      expect(account.fields[1].name).to eq 'Occupation'
      expect(account.fields[1].value).to eq 'Unit test'
    end
  end

  context 'identity proofs' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        attachment: [
          { type: 'IdentityProof', name: 'Alice', signatureAlgorithm: 'keybase', signatureValue: 'a' * 66 },
        ],
      }.with_indifferent_access
    end

    it 'parses out of attachment' do
      allow(ProofProvider::Keybase::Worker).to receive(:perform_async)

      account = subject.call('alice', 'example.com', payload)

      expect(account.identity_proofs.count).to eq 1

      proof = account.identity_proofs.first

      expect(proof.provider).to eq 'keybase'
      expect(proof.provider_username).to eq 'Alice'
      expect(proof.token).to eq 'a' * 66
    end

    it 'removes no longer present proofs' do
      allow(ProofProvider::Keybase::Worker).to receive(:perform_async)

      account   = Fabricate(:account, username: 'alice', domain: 'example.com')
      old_proof = Fabricate(:account_identity_proof, account: account, provider: 'keybase', provider_username: 'Bob', token: 'b' * 66)

      subject.call('alice', 'example.com', payload)

      expect(account.identity_proofs.count).to eq 1
      expect(account.identity_proofs.find_by(id: old_proof.id)).to be_nil
    end

    it 'queues a validity check on the proof' do
      allow(ProofProvider::Keybase::Worker).to receive(:perform_async)
      account = subject.call('alice', 'example.com', payload)
      expect(ProofProvider::Keybase::Worker).to have_received(:perform_async)
    end
  end

  context 'when account is not suspended' do
    let!(:account) { Fabricate(:account, username: 'alice', domain: 'example.com') }

    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        suspended: true,
      }.with_indifferent_access
    end

    before do
      allow(Admin::SuspensionWorker).to receive(:perform_async)
    end

    subject { described_class.new.call('alice', 'example.com', payload) }

    it 'suspends account remotely' do
      expect(subject.suspended?).to be true
      expect(subject.suspension_origin_remote?).to be true
    end

    it 'queues suspension worker' do
      subject
      expect(Admin::SuspensionWorker).to have_received(:perform_async)
    end
  end

  context 'when account is suspended' do
    let!(:account) { Fabricate(:account, username: 'alice', domain: 'example.com', display_name: '') }

    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        suspended: false,
        name: 'Hoge',
      }.with_indifferent_access
    end

    before do
      allow(Admin::UnsuspensionWorker).to receive(:perform_async)

      account.suspend!(origin: suspension_origin)
    end

    subject { described_class.new.call('alice', 'example.com', payload) }

    context 'locally' do
      let(:suspension_origin) { :local }

      it 'does not unsuspend it' do
        expect(subject.suspended?).to be true
      end

      it 'does not update any attributes' do
        expect(subject.display_name).to_not eq 'Hoge'
      end
    end

    context 'remotely' do
      let(:suspension_origin) { :remote }

      it 'unsuspends it' do
        expect(subject.suspended?).to be false
      end

      it 'queues unsuspension worker' do
        subject
        expect(Admin::UnsuspensionWorker).to have_received(:perform_async)
      end

      it 'updates attributes' do
        expect(subject.display_name).to eq 'Hoge'
      end
    end
  end
end
