# frozen_string_literal: true

module DomainNormalizable
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_domain
  end

  private

  def normalize_domain
    self.domain = TagManager.instance.normalize_domain(domain)
  end
end
