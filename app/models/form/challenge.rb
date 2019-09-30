# frozen_string_literal: true

class Form::Challenge
  include ActiveModel::Model

  attr_accessor :current_password, :current_username,
                :return_to
end
