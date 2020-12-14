# frozen_string_literal: true

class DirectoriesController < ApplicationController
  include WebAppControllerConcern

  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :require_enabled!

  skip_before_action :require_functional!, unless: :whitelist_mode?

  def index
    expires_in 0, public: true if current_account.nil?
  end

  private

  def require_enabled!
    not_found unless Setting.profile_directory
  end
end
