# frozen_string_literal: true

class Form::TwoFactorConfirmation
  include ActiveModel::Model

  attr_accessor :password, :code
end
