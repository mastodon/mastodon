# frozen_string_literal: true

class ProofProvider::Keybase::Worker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 20, unique: :until_executed

  sidekiq_retry_in do |count, exception|
    # Retry aggressively when the proof is valid but not live in Keybase.
    # This is likely because Keybase just hasn't noticed the proof being
    # served from here yet.

    if exception.class == ProofProvider::Keybase::ExpectedProofLiveError
      case count
      when 0..2 then 0.seconds
      when 2..6 then 1.second
      end
    end
  end

  def perform(proof_id)
    proof  = proof_id.is_a?(AccountIdentityProof) ? proof_id : AccountIdentityProof.find(proof_id)
    status = proof.provider_instance.verifier.status

    # If Keybase thinks the proof is valid, and it exists here in Mastodon,
    # then it should be live. Keybase just has to notice that it's here
    # and then update its state. That might take a couple seconds.
    raise ProofProvider::Keybase::ExpectedProofLiveError if status['proof_valid'] && !status['proof_live']

    proof.update!(verified: status['proof_valid'], live: status['proof_live'])
  end
end
