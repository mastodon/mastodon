# frozen_string_literal: true

module ProofProvider
  SUPPORTED_PROVIDERS = %w(keybase).freeze

  def self.find(identifier, proof = nil)
    case identifier
    when 'keybase'
      ProofProvider::Keybase.new(proof)
    end
  end
end
