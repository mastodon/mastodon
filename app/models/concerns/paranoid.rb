# frozen_string_literal: true

module Paranoid
  extend ActiveSupport::Concern

  included do
    scope :without_deleted, -> { where('deleted_at IS NULL') }
    scope :with_deleted,    -> { unscoped.recent }
    scope :only_deleted,    -> { with_deleted.where('deleted_at IS NOT NULL') }
  end

  def soft_destroy
    touch(:deleted_at)
  end

  alias soft_destroy! soft_destroy

  def destroyed?
    deleted_at.present? || super
  end
end
