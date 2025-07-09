# frozen_string_literal: true

class Disputes::BaseController < ApplicationController
  include Authorization

  layout 'admin'

  skip_before_action :require_functional!

  before_action :authenticate_user!
end
