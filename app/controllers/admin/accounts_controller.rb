# frozen_string_literal: true

class Admin::AccountsController < ApplicationController
  before_action :require_admin!

  layout 'public'

  def index
  end

  def show
  end
end
