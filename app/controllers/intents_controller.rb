# frozen_string_literal: true

class IntentsController < ApplicationController
  EXPECTED_SCHEME = 'web+mastodon'

  before_action :handle_invalid_uri, unless: :valid_uri?
  rescue_from Addressable::URI::InvalidURIError, with: :handle_invalid_uri

  def show
    case uri.host
    when 'follow'
      redirect_to authorize_interaction_path(uri: uri.query_values['uri'].delete_prefix('acct:'))
    when 'share'
      redirect_to share_path(text: uri.query_values['text'])
    else
      handle_invalid_uri
    end
  end

  private

  def valid_uri?
    uri.present? && uri.scheme == EXPECTED_SCHEME
  end

  def handle_invalid_uri
    not_found
  end

  def uri
    @uri ||= Addressable::URI.parse(params[:uri])
  end
end
