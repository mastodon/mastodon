# frozen_string_literal: true

class Admins::SessionsController < Devise::SessionsController
  def new
    flash[:special] = "Welcome to #{controller_path.inspect} controller!"
    super
  end
end
