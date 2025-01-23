# frozen_string_literal: true

class TermsOfService::Generator
  include ActiveModel::Model

  TEMPLATE = Rails.root.join('config', 'templates', 'terms-of-service.md').read

  VARIABLES = %i(
    admin_email
    arbitration_address
    arbitration_website
    dmca_address
    dmca_email
    domain
    jurisdiction
  ).freeze

  attr_accessor(*VARIABLES)

  validates(*VARIABLES, presence: true)

  def render
    format(TEMPLATE, VARIABLES.index_with { |key| public_send(key) })
  end
end
