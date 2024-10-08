# frozen_string_literal: true

class SharesController < ApplicationController
  layout 'modal'

  before_action :authenticate_user!

  def show; end
end
