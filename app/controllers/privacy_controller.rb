# frozen_string_literal: true

class PrivacyController < ApplicationController
  layout 'public'

  before_action :set_instance_presenter
  before_action :set_expires_in

  skip_before_action :require_functional!

  def show; end

  private

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def set_expires_in
    expires_in 0, public: true
  end
end
