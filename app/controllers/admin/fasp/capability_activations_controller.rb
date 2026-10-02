# frozen_string_literal: true

class Admin::Fasp::CapabilityActivationsController < Admin::BaseController
  before_action :set_capability_and_provider

  def create
    authorize [:admin, @provider], :update?

    @capability.update!(enabled: true)

    redirect_to edit_admin_fasp_provider_path(@provider),
                notice: I18n.t('admin.fasp.capabilities.activation_msg')
  end

  def destroy
    authorize [:admin, @provider], :update?

    @capability.update!(enabled: false)

    redirect_to edit_admin_fasp_provider_path(@provider),
                notice: I18n.t('admin.fasp.capabilities.deactivation_msg')
  end

  private

  def set_capability_and_provider
    @capability = Fasp::Capability.includes(:fasp_provider).find(params[:capability_id])
    @provider = @capability.fasp_provider
  end
end
