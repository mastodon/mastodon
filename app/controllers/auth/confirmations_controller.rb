# frozen_string_literal: true

class Auth::ConfirmationsController < Devise::ConfirmationsController
  layout 'auth'

  before_action :set_pack

  private

  def set_pack
    use_pack 'auth'
  end
end
