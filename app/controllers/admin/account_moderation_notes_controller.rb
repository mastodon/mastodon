# frozen_string_literal: true

class Admin::AccountModerationNotesController < Admin::BaseController
  def create
    @account_moderation_note = current_account.account_moderation_notes.new(resource_params)
    if @account_moderation_note.save
      @target_account = @account_moderation_note.target_account
      redirect_to admin_account_path(@target_account.id), notice: I18n.t('admin.account_moderation_notes.created_msg')
    else
      @account = @account_moderation_note.target_account
      @moderation_notes = @account.targeted_moderation_notes.latest
      render template: 'admin/accounts/show'
    end
  end

  def destroy
    @account_moderation_note = AccountModerationNote.find(params[:id])
    @target_account = @account_moderation_note.target_account
    @account_moderation_note.destroy
    redirect_to admin_account_path(@target_account.id), notice: I18n.t('admin.account_moderation_notes.destroyed_msg')
  end

  private

  def resource_params
    params.require(:account_moderation_note).permit(
      :content,
      :target_account_id
    )
  end
end
