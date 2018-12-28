# frozen_string_literal: true

require 'rails_helper'
require 'keybase_proof'

describe KeybaseProofWorker do
  let(:proof) { Fabricate(:account_identity_proof) }

  describe 'perform' do
    let(:remote_proof) { double(is_remote_valid?: true, is_remote_live?: false) }

    before do
      allow(Keybase::Proof).to receive(:new).
        with(proof.provider_username, proof.account.username, proof.token).
        and_return(remote_proof)
    end

    it 'calls Keybase::Proof object correctly' do
      expect(Keybase::Proof).to receive(:new).
        with(proof.provider_username, proof.account.username, proof.token).
        and_return(remote_proof)

      described_class.new.perform(proof.id)
    end

    it 'updates the proof with results from the Keybase::Proof' do
      expect {
        described_class.new.perform(proof.id)
        proof.reload
      }.to change { proof.is_valid }.from(nil).to(true)
        .and change { proof.is_live }.from(nil).to(false)
    end
  end
end
