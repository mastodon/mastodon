# frozen_string_literal: true

class AccountSuggestions::Suggestion < ActiveModelSerializers::Model
  attributes :account, :source

  delegate :id, to: :account, prefix: true
end
