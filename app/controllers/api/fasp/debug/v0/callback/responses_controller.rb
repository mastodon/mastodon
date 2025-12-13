# frozen_string_literal: true

class Api::Fasp::Debug::V0::Callback::ResponsesController < Api::Fasp::BaseController
  def create
    Fasp::DebugCallback.create(
      fasp_provider: current_provider,
      ip: request.remote_ip,
      request_body: request.raw_post
    )

    respond_to do |format|
      format.json { head 201 }
    end
  end
end
