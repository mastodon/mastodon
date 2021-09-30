# frozen_string_literal: true

class DirectoriesController < ApplicationController
  include WebAppControllerConcern

  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :require_enabled!

  skip_before_action :require_functional!, unless: :whitelist_mode?

  def index
    render :index
  end

  private

  def require_enabled!
    return not_found unless Setting.profile_directory
  end
end
