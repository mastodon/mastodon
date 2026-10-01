# frozen_string_literal: true

module ReauthConcern
  extend ActiveSupport::Concern

  def fulfil_reauth_request
    if session[:require_reauth_for]
      session[:reauthed_for] = session.delete(:require_reauth_for)
    else
      session.delete(:reauthed_for)
    end
  end
end
