# frozen_string_literal: true

class IntentsController < ApplicationController
  def show
    uri = Addressable::URI.parse(params[:uri])

    if uri.scheme == 'web+mastodon'
      case uri.host
      when 'follow'
        return redirect_to authorize_follow_path(acct: uri.query_values['uri'].gsub(/\Aacct:/, ''))
      when 'share'
        return redirect_to share_path(text: uri.query_values['text'])
      end
    end

    not_found
  end
end
