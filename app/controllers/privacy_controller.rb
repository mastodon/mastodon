# frozen_string_literal: true

class PrivacyController < ApplicationController
  include WebAppControllerConcern

  skip_before_action :require_functional!

  def show
    expires_in 0, public: true if current_account.nil?
  end
end
