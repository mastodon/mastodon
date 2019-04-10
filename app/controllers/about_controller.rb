# frozen_string_literal: true

class AboutController < ApplicationController
  before_action :set_pack
  layout 'public'

  before_action :set_instance_presenter, only: [:show, :more, :terms]

  def show
    @hide_navbar = true
  end

  def more; end

  def terms; end

  private

  def new_user
    User.new.tap do |user|
      user.build_account
      user.build_invite_request
    end
  end

  helper_method :new_user

  def set_pack
    use_pack 'common'
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
