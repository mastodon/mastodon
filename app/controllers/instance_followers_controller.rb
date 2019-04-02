# frozen_string_literal: true

class InstanceFollowersController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        mark_cacheable!

        next
      end

      format.json do
        mark_cacheable!
        raise Mastodon::NotPermittedError
      end
    end
  end
end
