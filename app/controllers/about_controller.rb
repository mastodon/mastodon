# frozen_string_literal: true

class AboutController < ApplicationController
  layout 'public'

  before_action :set_instance_presenter, only: [:show, :more, :terms]

  def show
    @hide_navbar = true
  end

  def more; end

  def terms; end

  private

  def new_user
    User.new.tap(&:build_account)
  end

  helper_method :new_user

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
