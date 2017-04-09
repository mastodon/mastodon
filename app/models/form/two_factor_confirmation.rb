# frozen_string_literal: true

class Form::TwoFactorConfirmation
  include ActiveModel::Model

  attr_accessor :code
end
