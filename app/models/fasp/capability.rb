# frozen_string_literal: true

class Fasp::Capability
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :string
  attribute :version, :string
  attribute :enabled, :boolean, default: false
end
