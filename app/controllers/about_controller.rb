# frozen_string_literal: true

class AboutController < ApplicationController
  include WebAppControllerConcern

  skip_before_action :require_functional!

  def show
    expires_in 0, public: true unless user_signed_in?
  end
end
