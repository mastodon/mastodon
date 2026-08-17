# frozen_string_literal: true

class Form::EmailSubscriptionsConfirmation
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :agreement_email_volume, :boolean
  attribute :agreement_privacy_and_terms, :boolean

  validates :agreement_email_volume, :agreement_privacy_and_terms, acceptance: true
end
