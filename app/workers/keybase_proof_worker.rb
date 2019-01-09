# frozen_string_literal: true

class KeybaseProofWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 20, unique: :until_executed

  def perform(proof_id)
    proof = AccountIdentityProof.keybase.with_account_username.find(proof_id)
    remote_status = Keybase::Proof.new(proof, proof.username).remote_status
    proof.assign_attributes(remote_status.slice(:is_valid, :is_live))

    proof.save!
  end
end
