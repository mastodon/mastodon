# frozen_string_literal: true
require 'uri'

class Hello::VerifiedController < ActionController::Base

  def index
    redirect_to Hello.mastodon_builder_url
  end
end
