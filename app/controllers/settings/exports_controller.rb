# frozen_string_literal: true

class Settings::ExportsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show
    @export = Export.new(current_account)
  end
end
