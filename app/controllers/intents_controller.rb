# frozen_string_literal: true

class IntentsController < ApplicationController
  def show
    uri = Addressable::URI.parse(params[:uri])

    if uri.scheme == 'web+mastodon'
      case uri.host
      when 'follow'
        redirect_to authorize_follow_path(acct: uri.query_values['uri'].gsub(/\Aacct:/, ''))
      else
        not_found
      end
    else
      not_found
    end
  end
end
