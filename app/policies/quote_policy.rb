# frozen_string_literal: true

class QuotePolicy < ApplicationPolicy
  def revoke?
    record.quoted_account_id.present? && record.quoted_account_id == current_account&.id
  end
end
