# frozen_string_literal: true

class REST::BaseSerializer < ActiveModel::Serializer
  def current_user?
    !current_user.nil?
  end
end
