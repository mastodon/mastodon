# frozen_string_literal: true

class Form::BaseBatch
  include ActiveModel::Model
  include Authorization
  include AccountableConcern

  attr_accessor :action,
                :current_account

  def save
    raise 'Override in subclass'
  end
end
