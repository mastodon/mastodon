# frozen_string_literal: true

class PrivacyController < ApplicationController
  include WebAppControllerConcern

  skip_before_action :require_functional!

  before_action :set_instance_presenter

  def show
    expires_in(15.seconds, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.day) unless user_signed_in?
  end

  private

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
