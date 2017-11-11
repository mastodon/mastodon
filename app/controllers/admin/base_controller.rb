# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Authorization

    before_action :require_staff!

    layout 'admin'
  end
end
