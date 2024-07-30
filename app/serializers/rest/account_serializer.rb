# frozen_string_literal: true

class REST::AccountSerializer < REST::BaseAccountSerializer
  has_one :moved_to_account, key: :moved, serializer: REST::AccountSerializer, if: :moved_and_not_nested?

  class AccountDecorator < SimpleDelegator
    def self.model_name
      Account.model_name
    end

    def moved?
      false
    end
  end

  def moved_to_account
    object.unavailable? ? nil : AccountDecorator.new(object.moved_to_account)
  end

  def moved_and_not_nested?
    object.moved?
  end
end
