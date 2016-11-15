# frozen_string_literal: true

class AboutController < ApplicationController
  before_action :set_body_classes

  def index
  end

  def terms
  end

  private

  def set_body_classes
    @body_classes = 'about-body'
  end
end
