# frozen_string_literal: true

class Admin::Instances::ModerationNotesController < Admin::BaseController
  before_action :set_instance, only: [:create]
  before_action :set_instance_note, only: [:destroy]

  def create
    authorize :instance_moderation_note, :create?

    @instance_moderation_note = current_account.instance_moderation_notes.new(content: resource_params[:content], domain: @instance.domain)

    if @instance_moderation_note.save
      redirect_to admin_instance_path(@instance.domain, anchor: helpers.dom_id(@instance_moderation_note)), notice: I18n.t('admin.instances.moderation_notes.created_msg')
    else
      @instance_moderation_notes = @instance.moderation_notes.includes(:account).chronological
      @time_period = (6.days.ago.to_date...Time.now.utc.to_date)
      @action_logs = Admin::ActionLogFilter.new(target_domain: @instance.domain).results.limit(5)

      render 'admin/instances/show'
    end
  end

  def destroy
    authorize @instance_moderation_note, :destroy?
    @instance_moderation_note.destroy!
    redirect_to admin_instance_path(@instance_moderation_note.domain, anchor: 'instance-notes'), notice: I18n.t('admin.instances.moderation_notes.destroyed_msg')
  end

  private

  def resource_params
    params
      .expect(instance_moderation_note: [:content])
  end

  def set_instance
    domain = params[:instance_id]&.strip
    @instance = Instance.find_or_initialize_by(domain: TagManager.instance.normalize_domain(domain))
  end

  def set_instance_note
    @instance_moderation_note = InstanceModerationNote.find(params[:id])
  end
end
