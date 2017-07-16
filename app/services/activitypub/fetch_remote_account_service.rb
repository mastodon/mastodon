# frozen_string_literal: true

class ActivityPub::FetchRemoteAccountService < BaseService
  def call(uri)
    response = Request.new(:get, uri).perform

    return nil unless response.code.successful?

    raise NotImplementedError
  end
end
