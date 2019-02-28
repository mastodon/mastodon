# frozen_string_literal: true

require 'rails_helper'
require 'keybase_proof'

describe KeybaseProofWorker do
  let(:proof) { Fabricate(:account_identity_proof) }

  describe 'perform' do
    before do
      allow(Keybase::Proof).to receive(:new).
        with(instance_of(AccountIdentityProof), proof.account.username).
        and_return(remote_proof)
    end

    context 'when the proof is valid and live' do
      let(:remote_proof) { double(remote_status: {proof_valid: true, proof_live: true}) }

      it 'calls Keybase::Proof object correctly' do
        expect(Keybase::Proof).to receive(:new).
          with(instance_of(AccountIdentityProof), proof.account.username).
          and_return(remote_proof)

        described_class.new.perform(proof.id)
      end

      it 'updates the proof with results from the Keybase::Proof' do
        expect {
          described_class.new.perform(proof.id)
          proof.reload
        }.to change { proof.proof_valid }.from(nil).to(true)
          .and change { proof.proof_live }.from(nil).to(true)
      end
    end

    context 'when the proof is valid but not live' do
      let(:remote_proof) { double(remote_status: {proof_valid: true, proof_live: false}) }

      it 'raises a custom exception to trigger retries' do
        expect {
          described_class.new.perform(proof.id)
        }.to raise_exception Keybase::ExpectedProofLiveError
      end
    end
  end
end
