# frozen_string_literal: true

class Api::V1::VersionController < ApiController
  def index
    render text: Mastodon::VERSION
  end
end
