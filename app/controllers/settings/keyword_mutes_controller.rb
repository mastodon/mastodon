# frozen_string_literal: true

class Settings::KeywordMutesController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
end
