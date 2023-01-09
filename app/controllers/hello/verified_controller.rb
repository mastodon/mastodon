# frozen_string_literal: true

class Hello::VerifiedController < ActionController::Base

  def index
    redirect_to Hello.mastodon_builder_url
  end
end
