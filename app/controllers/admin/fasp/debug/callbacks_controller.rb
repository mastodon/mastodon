# frozen_string_literal: true

class Admin::Fasp::Debug::CallbacksController < Admin::BaseController
  def index
    authorize [:admin, :fasp, :provider], :update?

    @callbacks = Fasp::DebugCallback
      .includes(:fasp_provider)
      .order(created_at: :desc)
  end

  def destroy
    authorize [:admin, :fasp, :provider], :update?

    callback = Fasp::DebugCallback.find(params[:id])
    callback.destroy

    redirect_to admin_fasp_debug_callbacks_path
  end
end
