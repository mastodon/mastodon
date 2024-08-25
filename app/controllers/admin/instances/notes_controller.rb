# frozen_string_literal: true

class Admin::Instances::NotesController < Admin::BaseController
  before_action :set_instance, only: [:create]
  before_action :set_instance_note, only: [:destroy]

  def create
    authorize :instance_note, :create?

    @instance_note = current_account.instance_notes.new(content: resource_params[:content], domain: @instance.domain)

    if @instance_note.save
      redirect_to admin_instance_path(@instance.domain, anchor: helpers.dom_id(@instance_note)), notice: I18n.t('admin.instances.notes.created_msg')
    else
      @instance_notes = @instance.notes.includes(:account).latest
      @time_period = (6.days.ago.to_date...Time.now.utc.to_date)
      @action_logs = Admin::ActionLogFilter.new(target_domain: @instance.domain).results.limit(5)

      render 'admin/instances/show'
    end
  end

  def destroy
    authorize @instance_note, :destroy?
    @instance_note.destroy!
    redirect_to admin_instance_path(@instance_note.domain, anchor: 'instance_notes'), notice: I18n.t('admin.instances.notes.destroyed_msg')
  end

  private

  def resource_params
    params.require(:instance_note).permit(
      :content
    )
  end

  def set_instance
    @instance = Instance.find_or_initialize_by(domain: TagManager.instance.normalize_domain(params[:instance_id]&.strip))
  end

  def set_instance_note
    @instance_note = InstanceNote.find(params[:id])
  end
end
