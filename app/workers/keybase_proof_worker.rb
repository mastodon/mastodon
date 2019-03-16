# frozen_string_literal: true

class KeybaseProofWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 20, unique: :until_executed
  sidekiq_retry_in do |count, exception|
    # Retry aggressively when the proof is valid but not live in Keybase.
    # This is likely because Keybase just hasn't noticed the proof being
    # served from here yet.
    if exception.class == Keybase::ExpectedProofLiveError
      case count
      when 0..2 then 0.seconds
      when 2..6 then 1.second
      end
    end
  end

  def perform(proof_id)
    proof = AccountIdentityProof.keybase.with_account_username.find(proof_id)
    remote_status = Keybase::Proof.new(proof, proof.username).remote_status

    if remote_status[:proof_valid] && !remote_status[:proof_live]
      # If Keybase thinks the proof is valid, and it exists here in Mastodon,
      # then it should be live. Keybase just has to notice that it's here
      # and then update its state. That might take a couple seconds.
      raise Keybase::ExpectedProofLiveError, "expected this proof to be live, but it's not yet."
    end

    proof.assign_attributes(remote_status.slice(:proof_valid, :proof_live))
    proof.save!
  end

  def perform_safe(proof_id)
    perform(proof_id)
  rescue Keybase::ResponseDataError
    nil
  end
end
