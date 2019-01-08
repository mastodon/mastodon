# frozen_string_literal: true

class IntentsController < ApplicationController
  before_action :check_uri
  rescue_from Addressable::URI::InvalidURIError, with: :handle_invalid_uri

  def show
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

  private

  def check_uri
    not_found if uri.blank?
  end

  def handle_invalid_uri
    not_found
  end

  def uri
    @uri ||= Addressable::URI.parse(params[:uri])
  end
end
