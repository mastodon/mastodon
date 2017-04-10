# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin!

    layout 'admin'
  end
end
