# frozen_string_literal: true

class SharesController < ApplicationController
  layout 'modal'

  before_action :authenticate_user!
  before_action :set_pack
  before_action :set_body_classes

  def show; end

  private

  def set_pack
    use_pack 'share'
  end

  def set_body_classes
    @body_classes = 'modal-layout compose-standalone'
  end
end
