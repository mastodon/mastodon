class AccountSuggestions::Suggestion < ActiveModelSerializers::Model
  attributes :account, :source

  delegate :id, to: :account, prefix: true
end
