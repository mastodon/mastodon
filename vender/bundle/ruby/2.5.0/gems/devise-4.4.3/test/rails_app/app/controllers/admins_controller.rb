# frozen_string_literal: true

class AdminsController < ApplicationController
  before_action :authenticate_admin!

  def index
  end
end
