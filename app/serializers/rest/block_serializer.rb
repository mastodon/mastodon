# frozen_string_literal: true

class REST::BlockSerializer < ActiveModel::Serializer
  attributes :stealth

  belongs_to :target_account, serializer: REST::AccountSerializer

  def stealth
    object.stealth?
  end
end
