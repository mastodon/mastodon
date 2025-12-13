# frozen_string_literal: true

class Admin::Fasp::DebugCallsController < Admin::BaseController
  before_action :set_provider

  def create
    authorize [:admin, @provider], :update?

    @provider.perform_debug_call

    redirect_to admin_fasp_providers_path
  end

  private

  def set_provider
    @provider = Fasp::Provider.find(params[:provider_id])
  end
end
