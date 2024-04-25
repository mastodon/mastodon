# frozen_string_literal: true

class REST::AppealSerializer < ActiveModel::Serializer
  attributes :text, :state

  def state
    if object.approved?
      'approved'
    elsif object.rejected?
      'rejected'
    else
      'pending'
    end
  end
end
