# frozen_string_literal: true

class Form::RecoveryCodeConfirmation
  include ActiveModel::Model

  attr_accessor :password, :code
end
