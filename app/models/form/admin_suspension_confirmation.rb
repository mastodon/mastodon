# frozen_string_literal: true

class Form::AdminSuspensionConfirmation
  include ActiveModel::Model

  attr_accessor :acct, :report_id
end
