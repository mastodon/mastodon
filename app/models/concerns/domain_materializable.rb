# frozen_string_literal: true

module DomainMaterializable
  extend ActiveSupport::Concern

  included do
    after_create_commit :refresh_instances_view
  end

  def refresh_instances_view
    Instance.refresh unless domain.nil? || Instance.where(domain: domain).exists?
  end
end
