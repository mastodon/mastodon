# frozen_string_literal: true

class KeybaseProofWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 20, unique: :until_executed

  def perform(proof_id)
    proof = AccountIdentityProof.keybase.with_account_username.find(proof_id)
    kb_proof = Keybase::Proof.new(proof.provider_username, proof.username, proof.token)
    proof.assign_attributes(is_valid: kb_proof.is_remote_valid?, is_live: kb_proof.is_remote_live?)

    proof.save!
  end
end
