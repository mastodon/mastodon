# frozen_string_literal: true

class REST::Shallow::AccountSerializer < REST::BaseAccountSerializer
  attribute :moved_to_account_id, if: :moved?

  def moved_to_account_id
    object.unavailable? ? nil : object.moved_to_account_id&.to_s
  end

  delegate :moved?, to: :object
end
