# frozen_string_literal: true

module Fasp::Provider::DebugConcern
  extend ActiveSupport::Concern

  def perform_debug_call
    Fasp::Request.new(self)
                 .post('/debug/v0/callback/logs', body: { hello: 'world' })
  end
end
